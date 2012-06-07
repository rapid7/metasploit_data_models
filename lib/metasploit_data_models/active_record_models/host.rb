module MetasploitDataModels::ActiveRecordModels::Host
  def self.included(base)
    base.class_eval{

      belongs_to :workspace, :class_name => "Mdm::Workspace"
      has_many :hosts_tags, :class_name => "Mdm::HostTag"
      has_many :tags, :through => :hosts_tags, :class_name => "Mdm::Tag"
      has_many :services, :dependent => :destroy, :class_name => "Mdm::Service", :order => "services.port, services.proto"
      has_many :clients, :dependent => :delete_all, :class_name => "Mdm::Client"
      has_many :vulns, :dependent => :delete_all, :class_name => "Mdm::Vuln"
      has_many :notes, :dependent => :delete_all, :class_name => "Mdm::Note", :order => "notes.created_at"
      has_many :loots, :dependent => :destroy, :class_name => "Mdm::Loot", :order => "loots.created_at desc"
      has_many :sessions, :dependent => :destroy, :class_name => "Mdm::Session", :order => "sessions.opened_at"

      has_many :service_notes, :through => :services
      has_many :web_sites, :through => :services, :class_name => "Mdm::WebSite"
      has_many :creds, :through => :services, :class_name => "Mdm::Cred"
      has_many :exploited_hosts, :dependent => :destroy, :class_name => "Mdm::ExploitedHost"

      has_many :host_details, :class_name => "Mdm::HostDetail"

      validates :address, :presence => true, :ip_format => true
      validates_exclusion_of :address, :in => ['127.0.0.1']
      validates_uniqueness_of :address, :scope => :workspace_id, :unless => Proc.new { |host| host.ip_address_invalid? }

      # This is replicated by the IpAddressValidator class. Had to put it here as well to avoid
      # SQL errors when checking address uniqueness.
      def ip_address_invalid?
        begin
          potential_ip = IPAddr.new(address)
          return true unless potential_ip.ipv4? || potential_ip.ipv6?
        rescue ArgumentError
          return true
        end
      end

      validates_presence_of :workspace

      scope :alive, where({'hosts.state' => 'alive'})
      scope :search, lambda { |*args| {:conditions =>
              		[ %w{address::text hosts.name os_name os_flavor os_sp mac purpose comments}.map{|c| "#{c} ILIKE ?"}.join(" OR ") ] + [ "%#{args[0]}%" ] * 8 }
              	}
      scope :tag_search,
            lambda { |*args| where("tags.name" => args[0]).includes(:tags) }

      scope :flagged, where('notes.critical = true AND notes.seen = false').includes(:notes)

      def is_vm?
        !!self.virtual_host
      end

      def attribute_locked?(attr)
        n = notes.find_by_ntype("host.updated.#{attr}")
        n && n.data[:locked]
      end

      accepts_nested_attributes_for :services, :reject_if => lambda { |s| s[:port].blank? }, :allow_destroy => true

      def before_destroy
        tags.each do |tag|
          tag.destroy if tag.hosts == [self]
        end
      end

      # Determine if the fingerprint data is readable. If not, it nearly always
      # means that there was a problem with the YAML or the Marshal'ed data,
      # so let's log that for later investigation.
      def validate_fingerprint_data(fp)
        if fp.data.kind_of?(Hash) and !fp.data.empty?
          return true
        elsif fp.ntype == "postgresql.fingerprint"
          # Special case postgresql.fingerprint; it's always a string,
          # and should not be used for OS fingerprinting (yet), so
          # don't bother logging it. TODO: fix os fingerprint finding, this
          # name collision seems silly.
          return false
        else
          dlog("Could not validate fingerprint data: #{fp.inspect}")
          return false
        end
      end

      #
      # Normalize the operating system fingerprints provided by various scanners
      # (nmap, nexpose, retina, nessus, etc).
      #
      # These are stored as notes (instead of directly in the os_* fields)
      # specifically for this purpose.
      #
      def normalize_os
        host = self

        wname = {} # os_name   == Linux, Windows, Mac OS X, VxWorks
        wtype = {} # purpose   == server, client, device
        wflav = {} # os_flavor == Ubuntu, Debian, 2003, 10.5, JetDirect
        wvers = {} # os_sp     == 9.10, SP2, 10.5.3, 3.05
        warch = {} # arch      == x86, PPC, SPARC, MIPS, ''
        wlang = {} # os_lang   == English, ''
        whost = {} # hostname

        # Note that we're already restricting the query to this host by using
        # host.notes instead of Note, so don't need a host_id in the
        # conditions.
        fingerprintable_notes = self.notes.where("ntype like '%%fingerprint'")
                                 fingerprintable_notes.each do |fp|
                                   next if not validate_fingerprint_data(fp)
                                   norm = normalize_scanner_fp(fp)
                                   wvers[norm[:os_sp]]     = wvers[norm[:os_sp]].to_i     + (100 * norm[:certainty])
                                   wname[norm[:os_name]]   = wname[norm[:os_name]].to_i   + (100 * norm[:certainty])
                                   wflav[norm[:os_flavor]] = wflav[norm[:os_flavor]].to_i + (100 * norm[:certainty])
                                   warch[norm[:arch]]      = warch[norm[:arch]].to_i      + (100 * norm[:certainty])
                                   whost[norm[:name]]      = whost[norm[:name]].to_i      + (100 * norm[:certainty])
                                   wtype[norm[:type]]      = wtype[norm[:type]].to_i      + (100 * norm[:certainty])
                                 end

                                 # Grab service information and assign scores. Some services are
                                 # more trustworthy than others. If more services agree than not,
                                 # than that should be considered as well.
                                 # Each service has a starting number of points. Services that
                                 # are more difficult to fake are awarded more points. The points
                                 # represent a running total, not a fixed score.
                                 # XXX: This needs to be refactored in a big way. Tie-breaking is
                                 # pretty arbitrary, it would be nice to explicitly believe some
                                 # services over others, but that means recording which service
                                 # has an opinion and which doesn't. It would also be nice to
                                 # identify "impossible" combinations of services and alert that
                                 # something funny is going on.
                                 # XXX: This hack solves the memory leak generated by self.services.each {}
        fingerprintable_services = self.services.where("name is not null and name != '' and info is not null and info != ''")
                                 fingerprintable_services.each do |s|
                                   points = 0
                                   case s.name
                                   when 'smb'
                                     points = 210
                                     case s.info
                                     when /\.el([23456])(\s+|$)/  # Match Samba 3.0.33-0.30.el4 as RHEL4
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav["RHEL" + $1] = wflav["RHEL" + $1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /(ubuntu|debian|fedora|red ?hat|rhel)/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav[$1.capitalize] = wflav[$1.capitalize].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /^Windows/
                                       win_sp   = nil
                                       win_flav = nil
                                       win_lang = nil

                                       ninfo = s.info
                                       ninfo.gsub!('(R)', '')
                                       ninfo.gsub!('(TM)', '')
                                       ninfo.gsub!(/\s+/, ' ')
                                       ninfo.gsub!('No Service Pack', 'Service Pack 0')

                                       # Windows (R) Web Server 2008 6001 Service Pack 1 (language: Unknown) (name:PG-WIN2008WEB) (domain:WORKGROUP)
                                       # Windows XP Service Pack 3 (language: English) (name:EGYPT-B3E55BF3C) (domain:EGYPT-B3E55BF3C)
                                       # Windows 7 Ultimate (Build 7600) (language: Unknown) (name:WIN7) (domain:WORKGROUP)
                                       # Windows 2003 No Service Pack (language: Unknown) (name:VMWIN2003) (domain:PWNME)

                                       #if ninfo =~ /^Windows ([^\s]+)(.*)(Service Pack |\(Build )([^\(]+)\(/
                                       if ninfo =~ /^Windows (.*)(Service Pack [^\s]+|\(Build [^\)]+\))/
                                         win_flav = $1.strip
                                         win_sp   = ($2).strip
                                         win_sp.gsub!(/with.*/, '')
                                         win_sp.gsub!('Service Pack', 'SP')
                                         win_sp.gsub!('Build', 'b')
                                         win_sp.gsub!(/\s+/, '')
                                         win_sp.tr!("()", '')
                                       else
                                         if ninfo =~ /^Windows ([^\s+]+)([^\(]+)\(/
                                                                                  win_flav = $2.strip
                                         end
                                       end


                                       if ninfo =~ /name: ([^\)]+)\)/
                                         hostname = $1.strip
                                       end

                                       if ninfo =~ /language: ([^\)]+)\)/
                                         win_lang = $1.strip
                                       end

                                       win_lang = nil if win_lang =~ /unknown/i
                                       win_vers = win_sp

                                       wname['Microsoft Windows'] = wname['Microsoft Windows'].to_i + points
                                       wlang[win_lang] = wlang[win_lang].to_i + points if win_lang
                                       wflav[win_flav] = wflav[win_flav].to_i + points if win_flav
                                       wvers[win_vers] = wvers[win_vers].to_i + points if win_vers
                                       whost[hostname] = whost[hostname].to_i + points if hostname

                                       case win_flav
                                       when /NT|2003|2008/
                                         win_type = 'server'
                                       else
                                         win_type = 'client'
                                       end
                                       wtype[win_type] = wtype[win_type].to_i + points
                                     end

                                   when 'ssh'
                                     points = 104
                                     case s.info
                                     when /honeypot/i # Never trust this
                                       nil
                                     when /ubuntu/i
                                       # This needs to be above /debian/ becuase the ubuntu banner contains both, e.g.:
                                       # SSH-2.0-OpenSSH_5.3p1 Debian-3ubuntu6
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Ubuntu'] = wflav['Ubuntu'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /debian/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Debian'] = wflav['Debian'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /FreeBSD/
                                       wname['FreeBSD'] = wname['FreeBSD'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /sun_ssh/i
                                       wname['Sun Solaris'] = wname['Sun Solaris'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /vshell|remotelyanywhere|freessh/i
                                       wname['Microsoft Windows'] = wname['Microsoft Windows'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /radware/i
                                       wname['RadWare'] = wname['RadWare'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /dropbear/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /netscreen/i
                                       wname['NetScreen'] = wname['NetScreen'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /vpn3/
                                       wname['Cisco VPN 3000'] = wname['Cisco VPN 3000'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /cisco/i
                                       wname['Cisco IOS'] = wname['Cisco IOS'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /mpSSH/
                                       wname['HP iLO'] = wname['HP iLO'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     end
                                   when 'http'
                                     points = 99
                                     case s.info
                                     when /iSeries/
                                       wname['IBM iSeries'] = wname['IBM iSeries'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Mandrake/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Mandrake'] = wflav['Mandrake'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Mandriva/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Mandrake'] = wflav['Mandrake'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Ubuntu/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Ubuntu'] = wflav['Ubuntu'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Debian/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Debian'] = wflav['Debian'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Fedora/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Fedora'] = wflav['Fedora'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /CentOS/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['CentOS'] = wflav['CentOS'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /RHEL/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['RHEL'] = wflav['RHEL'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Red.?Hat/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Red Hat'] = wflav['Red Hat'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /SuSE/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['SUSE'] = wflav['SUSE'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /TurboLinux/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['TurboLinux'] = wflav['TurboLinux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Gentoo/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Gentoo'] = wflav['Gentoo'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Conectiva/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Conectiva'] = wflav['Conectiva'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Asianux/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Asianux'] = wflav['Asianux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Trustix/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Trustix'] = wflav['Trustix'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /White Box/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['White Box'] = wflav['White Box'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /UnitedLinux/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['UnitedLinux'] = wflav['UnitedLinux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /PLD\/Linux/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['PLD/Linux'] = wflav['PLD/Linux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Vine\/Linux/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Vine/Linux'] = wflav['Vine/Linux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /rPath/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['rPath'] = wflav['rPath'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /StartCom/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['StartCom'] = wflav['StartCom'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /linux/i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /PalmOS/
                                       wname['PalmOS'] = wname['PalmOS'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /Microsoft[\x20\x2d]IIS\/[234]\.0/
                                       wname['Microsoft Windows NT 4.0'] = wname['Microsoft Windows NT 4.0'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Microsoft[\x20\x2d]IIS\/5\.0/
                                       wname['Microsoft Windows 2000'] = wname['Microsoft Windows 2000'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Microsoft[\x20\x2d]IIS\/5\.1/
                                       wname['Microsoft Windows XP'] = wname['Microsoft Windows XP'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Microsoft[\x20\x2d]IIS\/6\.0/
                                       wname['Microsoft Windows 2003'] = wname['Microsoft Windows 2003'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Microsoft[\x20\x2d]IIS\/7\.0/
                                       wname['Microsoft Windows 2008'] = wname['Microsoft Windows 2008'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Win32/i
                                       wname['Microsoft Windows'] = wname['Microsoft Windows'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /DD\-WRT ([^\s]+) /i
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['DD-WRT'] = wflav['DD-WRT'].to_i + points
                                       wvers[$1.strip] = wvers[$1.strip].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /Darwin/
                                       wname['Apple Mac OS X'] = wname['Apple Mac OS X'].to_i + points

                                     when /FreeBSD/i
                                       wname['FreeBSD'] = wname['FreeBSD'].to_i + points

                                     when /OpenBSD/i
                                       wname['OpenBSD'] = wname['OpenBSD'].to_i + points

                                     when /NetBSD/i
                                       wname['NetBSD'] = wname['NetBSD'].to_i + points

                                     when /NetWare/i
                                       wname['Novell NetWare'] = wname['Novell NetWare'].to_i + points

                                     when /OpenVMS/i
                                       wname['OpenVMS'] = wname['OpenVMS'].to_i + points

                                     when /SunOS|Solaris/i
                                       wname['Sun Solaris'] = wname['Sun Solaris'].to_i + points

                                     when /HP.?UX/i
                                       wname['HP-UX'] = wname['HP-UX'].to_i + points
                                     end
                                   when 'snmp'
                                     points = 103
                                     case s.info
                                     when /^Sun SNMP Agent/
                                       wname['Sun Solaris'] = wname['Sun Solaris'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^SunOS ([^\s]+) ([^\s]+) /
                                       # XXX 1/2 XXX what does this comment mean i wonder
                                       wname['Sun Solaris'] = wname['Sun Solaris'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Linux ([^\s]+) ([^\s]+) /
                                       whost[$1] = whost[$1].to_i + points
                                       wname['Linux ' + $2] = wname['Linux ' + $2].to_i + points
                                       wvers[$2] = wvers[$2].to_i + points
                                       arch = get_arch_from_string(s.info)
                                       warch[arch] = warch[arch].to_i + points if arch
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Novell NetWare ([^\s]+)/
                                       wname['Novell NetWare ' + $1] = wname['Novell NetWare ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       arch = "x86"
                                       warch[arch] = warch[arch].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Novell UnixWare ([^\s]+)/
                                       wname['Novell UnixWare ' + $1] = wname['Novell UnixWare ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       arch = "x86"
                                       warch[arch] = warch[arch].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^HP-UX ([^\s]+) ([^\s]+) /
                                       # XXX
                                       wname['HP-UX ' + $2] = wname['HP-UX ' + $2].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^IBM PowerPC.*Base Operating System Runtime AIX version: (\d+\.\d+)/
                                       wname['IBM AIX ' + $1] = wname['IBM AIX ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^SCO TCP\/IP Runtime Release ([^\s]+)/
                                       wname['SCO UnixWare ' + $1] = wname['SCO UnixWare ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /.* IRIX version ([^\s]+)/
                                       wname['SGI IRIX ' + $1] = wname['SGI IRIX ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Unisys ([^\s]+) version ([^\s]+) kernel/
                                       wname['Unisys ' + $2] = wname['Unisys ' + $2].to_i + points
                                       wvers[$2] = wvers[$2].to_i + points
                                       whost[$1] = whost[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /.*OpenVMS V([^\s]+) /
                                       # XXX
                                       wname['OpenVMS ' + $1] = wname['OpenVMS ' + $1].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Hardware:.*Software: Windows NT Version ([^\s]+) /
                                       wname['Microsoft Windows NT ' + $1] = wname['Microsoft Windows NT ' + $1].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Hardware:.*Software: Windows 2000 Version 5\.0/
                                       wname['Microsoft Windows 2000'] = wname['Microsoft Windows 2000'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Hardware:.*Software: Windows 2000 Version 5\.1/
                                       wname['Microsoft Windows XP'] = wname['Microsoft Windows XP'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                     when /^Hardware:.*Software: Windows Version 5\.2/
                                       wname['Microsoft Windows 2003'] = wname['Microsoft Windows 2003'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points

                                       # XXX: TODO 2008, Vista, Windows 7

                                     when /^Microsoft Windows CE Version ([^\s]+)+/
                                       wname['Microsoft Windows CE ' + $1] = wname['Microsoft Windows CE ' + $1].to_i + points
                                       wtype['client'] = wtype['client'].to_i + points

                                     when /^IPSO ([^\s]+) ([^\s]+) /
                                       whost[$1] = whost[$1].to_i + points
                                       wname['Nokia IPSO ' + $2] = wname['Nokia IPSO ' + $2].to_i + points
                                       wvers[$2] = wvers[$2].to_i + points
                                       arch = get_arch_from_string(s.info)
                                       warch[arch] = warch[arch].to_s + points if arch
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /^Sun StorEdge/
                                       wname['Sun StorEdge'] = wname['Sun StorEdge'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /^HP StorageWorks/
                                       wname['HP StorageWorks'] = wname['HP StorageWorks'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /^Network Storage/
                                       # XXX
                                       wname['Network Storage Router'] = wname['Network Storage Router'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /Cisco Internetwork Operating System.*Version ([^\s]+)/
                                       vers = $1.split(/[,^\s]/)[0]
                                       wname['Cisco IOS ' + vers] = wname['Cisco IOS ' + vers].to_i + points
                                       wvers[vers] = wvers[vers].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /Cisco Catalyst.*Version ([^\s]+)/
                                       vers = $1.split(/[,^\s]/)[0]
                                       wname['Cisco CatOS ' + vers] = wname['Cisco CatOS ' + vers].to_i + points
                                       wvers[vers] = wvers[vers].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /Cisco 761.*Version ([^\s]+)/
                                       vers = $1.split(/[,^\s]/)[0]
                                       wname['Cisco 761 ' + vers] = wname['Cisco 761 ' + vers].to_i + points
                                       wvers[vers] = wvers[vers].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /Network Analysis Module.*Version ([^\s]+)/
                                       vers = $1.split(/[,^\s]/)[0]
                                       wname['Cisco NAM ' + vers] = wname['Cisco NAM ' + vers].to_i + points
                                       wvers[vers] = wvers[vers].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /VPN 3000 Concentrator Series Version ([^\s]+)/
                                       vers = $1.split(/[,^\s]/)[0]
                                       wname['Cisco VPN 3000 ' + vers] = wname['Cisco VPN 3000 ' + vers].to_i + points
                                       wvers[vers] = wvers[vers].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /ProCurve.*Switch/
                                       wname['3Com ProCurve Switch'] = wname['3Com ProCurve Switch'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /ProCurve.*Access Point/
                                       wname['3Com Access Point'] = wname['3Com Access Point'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /3Com.*Access Point/i
                                       wname['3Com Access Point'] = wname['3Com Access Point'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /ShoreGear/
                                       wname['ShoreTel Appliance'] = wname['ShoreTel Appliance'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /firewall/i
                                       wname['Unknown Firewall'] = wname['Unknown Firewall'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /phone/i
                                       wname['Unknown Phone'] = wname['Unknown Phone'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /router/i
                                       wname['Unknown Router'] = wname['Unknown Router'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points

                                     when /switch/i
                                       wname['Unknown Switch'] = wname['Unknown Switch'].to_i + points
                                       wtype['device'] = wtype['device'].to_i + points
                                       #
                                       # Printer Signatures
                                       #
                                     when /^HP ETHERNET MULTI-ENVIRONMENT/
                                       wname['HP Printer'] = wname['HP Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Canon/i
                                       wname['Canon Printer'] = wname['Canon Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Epson/i
                                       wname['Epson Printer'] = wname['Epson Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /ExtendNet/i
                                       wname['ExtendNet Printer'] = wname['ExtendNet Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Fiery/i
                                       wname['Fiery Printer'] = wname['Fiery Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Konica/i
                                       wname['Konica Printer'] = wname['Konica Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Lanier/i
                                       wname['Lanier Printer'] = wname['Lanier Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Lantronix/i
                                       wname['Lantronix Printer'] = wname['Lantronix Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Lexmark/i
                                       wname['Lexmark Printer'] = wname['Lexmark Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Magicolor/i
                                       wname['Magicolor Printer'] = wname['Magicolor Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Minolta/i
                                       wname['Minolta Printer'] = wname['Minolta Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /NetJET/i
                                       wname['NetJET Printer'] = wname['NetJET Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /OKILAN/i
                                       wname['OKILAN Printer'] = wname['OKILAN Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Phaser/i
                                       wname['Phaser Printer'] = wname['Phaser Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /PocketPro/i
                                       wname['PocketPro Printer'] = wname['PocketPro Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Ricoh/i
                                       wname['Ricoh Printer'] = wname['Ricoh Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Savin/i
                                       wname['Savin Printer'] = wname['Savin Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /SHARP AR/i
                                       wname['SHARP Printer'] = wname['SHARP Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Star Micronix/i
                                       wname['Star Micronix Printer'] = wname['Star Micronix Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Source Tech/i
                                       wname['Source Tech Printer'] = wname['Source Tech Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Xerox/i
                                       wname['Xerox Printer'] = wname['Xerox Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /^Brother/i
                                       wname['Brother Printer'] = wname['Brother Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /^Axis.*Network Print/i
                                       wname['Axis Printer'] = wname['Axis Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /^Prestige/i
                                       wname['Prestige Printer'] = wname['Prestige Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /^ZebraNet/i
                                       wname['ZebraNet Printer'] = wname['ZebraNet Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /e\-STUDIO/i
                                       wname['eStudio Printer'] = wname['eStudio Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /^Gestetner/i
                                       wname['Gestetner Printer'] = wname['Gestetner Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /IBM.*Print/i
                                       wname['IBM Printer'] = wname['IBM Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /HP (Color|LaserJet|InkJet)/i
                                       wname['HP Printer'] = wname['HP Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Dell (Color|Laser|Ink)/i
                                       wname['Dell Printer'] = wname['Dell Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     when /Print/i
                                       wname['Unknown Printer'] = wname['Unknown Printer'].to_i + points
                                       wtype['printer'] = wtype['printer'].to_i + points
                                     end # End of s.info for SNMP

                                   when 'telnet'
                                     points = 105
                                     case s.info
                                     when /IRIX/
                                       wname['SGI IRIX'] = wname['SGI IRIX'].to_i + points
                                     when /AIX/
                                       wname['IBM AIX'] = wname['IBM AIX'].to_i + points
                                     when /(FreeBSD|OpenBSD|NetBSD)\/(.*) /
                                       wname[$1] = wname[$1].to_i + points
                                       arch = get_arch_from_string($2)
                                       warch[arch] = warch[arch].to_i + points
                                     when /Ubuntu (\d+(\.\d+)+)/
                                       wname['Linux'] = wname['Linux'].to_i + points
                                       wflav['Ubuntu'] = wflav['Ubuntu'].to_i + points
                                       wvers[$1] = wvers[$1].to_i + points
                                     when /User Access Verification/
                                       wname['Cisco IOS'] = wname['Cisco IOS'].to_i + points
                                     when /Microsoft/
                                       wname['Microsoft Windows'] = wname['Microsoft Windows'].to_i + points
                                     end # End of s.info for TELNET
                                     wtype['server'] = wtype['server'].to_i + points

                                   when 'smtp'
                                     points = 103
                                     case s.info
                                     when /ESMTP.*SGI\.8/
                                       wname['SGI IRIX'] = wname['SGI IRIX'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     end # End of s.info for SMTP

                                   when 'https'
                                     points = 101
                                     case s.info
                                     when /(VMware\s(ESXi?)).*\s([\d\.]+)/
                                       # Very reliable fingerprinting from our own esx_fingerprint module
                                       wname[$1] = wname[$1].to_i + (points * 5)
                                       wflav[$3] = wflav[$3].to_i + (points * 5)
                                       wtype['device'] = wtype['device'].to_i + points
                                     end # End of s.info for HTTPS

                                   when 'netbios'
                                     points = 201
                                     case s.info
                                     when /W2K3/i
                                       wname['Microsoft Windows 2003'] = wname['Microsoft Windows 2003'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     when /W2K8/i
                                       wname['Microsoft Windows 2008'] = wname['Microsoft Windows 2008'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     end # End of s.info for NETBIOS

                                   when 'dns'
                                     points = 101
                                     case s.info
                                     when 'Microsoft DNS'
                                       wname['Microsoft Windows'] = wname['Microsoft Windows'].to_i + points
                                       wtype['server'] = wtype['server'].to_i + points
                                     end # End of s.info for DNS
                                   end # End of s.name case
                                   # End of Services
                                 end

                                 #
                                 # Report the best match here
                                 #
                                 best_match = {}
                                 best_match[:os_name]   = wname.keys.sort{|a,b| wname[b] <=> wname[a]}[0]
                                 best_match[:purpose]   = wtype.keys.sort{|a,b| wtype[b] <=> wtype[a]}[0]
                                 best_match[:os_flavor] = wflav.keys.sort{|a,b| wflav[b] <=> wflav[a]}[0]
                                 best_match[:os_sp]     = wvers.keys.sort{|a,b| wvers[b] <=> wvers[a]}[0]
                                 best_match[:arch]      = warch.keys.sort{|a,b| warch[b] <=> warch[a]}[0]
                                 best_match[:name]      = whost.keys.sort{|a,b| whost[b] <=> whost[a]}[0]
                                 best_match[:os_lang]   = wlang.keys.sort{|a,b| wlang[b] <=> wlang[a]}[0]

                                 best_match[:os_flavor] ||= host[:os_flavor] || ""
                                 if best_match[:os_name]
                                   # Handle cases where the flavor contains the base name
                                   # Don't use gsub!() here because the string was a hash key in a
                                   # previously life and gets frozen on 1.9.1, see #4128
                                   best_match[:os_flavor] = best_match[:os_flavor].gsub(best_match[:os_name], '')
                                 end

                                 # If we didn't get anything, use whatever the host already has.
                                 # Failing that, fallback to "Unknown"
                                 best_match[:os_name] ||= host[:os_name] || 'Unknown'
                                 best_match[:purpose] ||= 'device'

                                 [:os_name, :purpose, :os_flavor, :os_sp, :arch, :name, :os_lang].each do |host_attr|
                                   next if host.attribute_locked? host_attr
                                   if best_match[host_attr]
                                     host[host_attr] = Rex::Text.ascii_safe_hex(best_match[host_attr])
                                   end
                                 end

                                 host.save if host.changed?
      end

      protected

      #
      # Convert a host.os.*_fingerprint Note into a hash containing the standard os_* fields
      #
      # Also includes a :certainty which is a float from 0 - 1.00 indicating the
      # scanner's confidence in its fingerprint.  If the particular scanner does
      # not provide such information, defaults to 0.80.
      #
      # TODO: This whole normalize scanner procedure needs to be shoved off to its own
      # mixin. It's far too long and convoluted, has a ton of repeated code, and is
      # a massive hassle to update with new fingerprints.
      def normalize_scanner_fp(fp)
        return {} if not validate_fingerprint_data(fp)
        ret  = {}
        data = fp.data
        case fp.ntype
        when 'host.os.session_fingerprint'
          # These come from meterpreter sessions' client.sys.config.sysinfo
          case data[:os]
          when /Windows/
            ret.update(parse_windows_os_str(data[:os]))
          when /Linux ([^[:space:]]*) ([^[:space:]]*) .* (\(.*\))/
            ret[:os_name] = "Linux"
            ret[:name]    = $1
            ret[:os_sp]   = $2
            ret[:arch]    = get_arch_from_string($3)
          else
            ret[:os_name] = data[:os]
          end
          ret[:arch] = data[:arch] if data[:arch]
          ret[:name] = data[:name] if data[:name]

        when 'host.os.nmap_fingerprint', 'host.os.mbsa_fingerprint'
          # :os_vendor=>"Microsoft" :os_family=>"Windows" :os_version=>"2000" :os_accuracy=>"94"
          #
          # :os_match=>"Microsoft Windows Vista SP0 or SP1, Server 2008, or Windows 7 Ultimate (build 7000)"
          #    :os_vendor=>"Microsoft" :os_family=>"Windows" :os_version=>"7" :os_accuracy=>"100"
          ret[:certainty] = data[:os_accuracy].to_f / 100.0
          if (data[:os_vendor] == data[:os_family])
            ret[:os_name] = data[:os_family]
          else
            ret[:os_name] = data[:os_vendor] + " " + data[:os_family]
          end
          ret[:os_flavor] = data[:os_version]
          ret[:name] = data[:hostname] if data[:hostname]

        when 'host.os.nexpose_fingerprint'
          # :family=>"Windows" :certainty=>"0.85" :vendor=>"Microsoft" :product=>"Windows 7 Ultimate Edition"
          # :family=>"Linux" :certainty=>"0.64" :vendor=>"Linux" :product=>"Linux"
          # :family=>"Linux" :certainty=>"0.80" :vendor=>"Ubuntu" :product=>"Linux"
          # :family=>"IOS" :certainty=>"0.80" :vendor=>"Cisco" :product=>"IOS"
          # :family=>"embedded" :certainty=>"0.61" :vendor=>"Linksys" :product=>"embedded"
          ret[:certainty] = data[:certainty].to_f
          case data[:family]
          when /AIX|ESX|Mac OS X|OpenSolaris|Solaris|IOS|Linux/
            if data[:vendor] == data[:family]
              ret[:os_name] = data[:vendor]
            else
              # family often contains the vendor string, so rip it out to
              # avoid useless duplication
              ret[:os_name] = data[:vendor].to_s + " " + data[:family].to_s.gsub(data[:vendor].to_s, '').strip
            end
          when "Windows"
            ret[:os_name] = "Microsoft Windows"
            if data[:product]
              if data[:product][/2008/] && data[:version].to_i == 7
                ret[:os_flavor] = "Windows 7"
                ret[:type] = "client"
              else
                ret[:os_flavor] = data[:product].gsub("Windows", '').strip 
                ret[:os_sp] = data[:version] if data[:version]
                if data[:product]
                  ret[:type] = "server" if data[:product][/Server/]
                  ret[:type] = "client" if data[:product][/^(XP|ME)$/]
                end
              end
            end
          when "embedded"
            ret[:os_name] = data[:vendor]
          else
            ret[:os_name] = data[:vendor]
          end
          ret[:arch] = get_arch_from_string(data[:arch]) if data[:arch]
          ret[:arch] ||= get_arch_from_string(data[:desc]) if data[:desc]

        when 'host.os.retina_fingerprint'
          # :os=>"Windows Server 2003 (X64), Service Pack 2"
          case data[:os]
          when /Windows/
            ret.update(parse_windows_os_str(data[:os]))
          else
            # No idea what this looks like if it isn't windows.  Just store
            # the whole thing and hope for the best.  XXX: Ghetto.  =/
            ret[:os_name] = data[:os]
          end
        when 'host.os.nessus_fingerprint'
          # :os=>"Microsoft Windows 2000 Advanced Server (English)"
          # :os=>"Microsoft Windows 2000\nMicrosoft Windows XP"
          # :os=>"Linux Kernel 2.6"
          # :os=>"Sun Solaris 8"
          # :os=>"IRIX 6.5"

          # Nessus sometimes jams multiple OS names together with a newline.
          oses = data[:os].split(/\n/)
          if oses.length > 1
            # Multiple fingerprints means Nessus wasn't really sure, reduce
            # the certainty accordingly
            ret[:certainty] = 0.5
          else
            ret[:certainty] = 0.8
          end

          # Since there is no confidence associated with them, the best we
          # can do is just take the first one.
          case oses.first
          when /Windows/
            ret.update(parse_windows_os_str(data[:os]))

          when /(2\.[46]\.\d+[-a-zA-Z0-9]+)/
            # Linux kernel version
            ret[:os_name] = "Linux"
            ret[:os_sp] = $1
          when /(.*)?((\d+\.)+\d+)$/
            # Then we don't necessarily know what the os is, but this
            # fingerprint has some version information at the end, pull it
            # off.
            # When Nessus doesn't know what kind of linux it has, it gives an os like
            #  "Linux Kernel 2.6"
            # The "Kernel" string is useless, so cut it off.
            ret[:os_name] = $1.gsub("Kernel", '').strip
            ret[:os_sp] = $2
          else
            ret[:os_name] = oses.first
          end

          ret[:name] = data[:hname]
        when 'host.os.qualys_fingerprint'
          # :os=>"Microsoft Windows 2000"
          # :os=>"Windows 2003"
          # :os=>"Microsoft Windows XP Professional SP3"
          # :os=>"Ubuntu Linux"
          # :os=>"Cisco IOS 12.0(3)T3"
          case data[:os]
          when /Windows/
            ret.update(parse_windows_os_str(data[:os]))
          else
            parts = data[:os].split(/\s+/, 3)
            ret[:os_name] = "<unknown>"
            ret[:os_name] = parts[0] if parts[0]
            ret[:os_name] << " " + parts[1] if parts[1]
            ret[:os_sp]   = parts[2] if parts[2]
          end
          # XXX: We should really be using smb_version's stored fingerprints
          # instead of parsing the service info manually. Disable for now so we
          # don't count smb twice.
          #when 'smb.fingerprint'
          #	# smb_version is kind enough to store everything we need directly
          #	ret.merge(fp.data)
          #	# If it's windows, this should be a pretty high-confidence
          #	# fingerprint.  Otherwise, it's samba which doesn't give us much of
          #	# anything in most cases.
          #	ret[:certainty] = 1.0 if fp.data[:os_name] =~ /Windows/
        else
          # If you've fallen through this far, you've hit a generalized
          # pass-through fingerprint parser.
          ret[:os_name] = data[:os_name] || data[:os] || data[:os_fingerprint] || "<unknown>"
          ret[:type] = data[:os_purpose] if data[:os_purpose]
          ret[:arch] = data[:os_arch] if data[:os_arch]
          ret[:certainty] = data[:os_certainty] || 0.5
        end
        ret[:certainty] ||= 0.8
        ret
      end

      #
      # Take a windows version string and return a hash with fields suitable for
      # Host this object's version fields.
      #
      # A few example strings that this will have to parse:
      # sessions
      #   Windows XP (Build 2600, Service Pack 3).
      #   Windows .NET Server (Build 3790).
      #   Windows 2008 (Build 6001, Service Pack 1).
      # retina
      #   Windows Server 2003 (X64), Service Pack 2
      # nessus
      #   Microsoft Windows 2000 Advanced Server (English)
      # qualys
      #   Microsoft Windows XP Professional SP3
      #   Windows 2003
      #
      # Note that this list doesn't include nexpose or nmap, since they are
      # both kind enough to give us the various strings in seperate pieces
      # that we don't have to parse out manually.
      #
      def parse_windows_os_str(str)
        ret = {}

        ret[:os_name] = "Microsoft Windows"
        arch = get_arch_from_string(str)
        ret[:arch] = arch if arch

        if str =~ /(Service Pack|SP) ?(\d+)/
          ret[:os_sp]  = "SP#{$2}"
        end

        # Flavor
        case str
        when /\.NET Server/
          ret[:os_flavor] = "2003"
        when /(XP|2000 Advanced Server|2000|2003|2008|SBS|Vista|7 .* Edition|7)/
          ret[:os_flavor] = $1
        else
          # If we couldn't pull out anything specific for the flavor, just cut
          # off the stuff we know for sure isn't it and hope for the best
          ret[:os_flavor] ||= str.gsub(/(Microsoft )?Windows|(Service Pack|SP) ?(\d+)/, '').strip
        end

        if str =~ /NT|2003|2008|SBS|Server/
          ret[:type] = 'server'
        else
          ret[:type] = 'client'
        end

        ret
      end

      # A case switch to return a normalized arch based on a given string.
      def get_arch_from_string(str)
        case str
        when /x64|amd64|x86_64/i
          "x64"
        when /x86|i[3456]86/i
          "x86"
        when /PowerPC|PPC|POWER|ppc/
          "ppc"
        when /SPARC/i
          "sparc"
        when /MIPS/i
          "mips"
        when /ARM/i
          "arm"
        else
          nil
        end
      end
    
    } # end class_eval block
  end
end

