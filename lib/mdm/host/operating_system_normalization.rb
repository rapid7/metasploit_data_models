module Mdm::Host::OperatingSystemNormalization

  #
  # Leverage the Recog gem as much as possible for sane fingerprint management
  #
  require 'recog'

  #
  # Rules for operating system fingerprinting in Metasploit
  #
  # The os.product key identifies the common-name of a specific operating system
  #  Examples: Linux, Windows XP, Mac OS X, IOS, AIX, HP-UX, VxWorks
  #
  # The os.version key identifies the service pack or version of the operating system
  # Sometimes this means a kernel or firmware version when the distribution or OS
  # version is not available.
  #  Examples: SP2, 10.04, 2.6.47, 10.6.1
  #
  # The os.vendor key identifies the manufacturer of the operating system
  #  Examples: Microsoft, Ubuntu, Cisco, HP, IBM, Wind River
  #
  # The os.family key identifies the group of the operating system. This is often a
  # duplicate of os.product, unless a more specific product name is available.
  #  Examples: Windows, Linux, IOS, HP-UX, AIX
  #
  # The os.edition key identifies the specific variant of the operating system
  #  Examples: Enterprise, Professional, Starter, Evaluation, Home, Datacenter
  #
  # An example breakdown of a common operating system is shown below
  #
  #  * Microsoft Windows XP Professional Service Pack 3 English (x86)
  #  -> os.product  = 'Windows XP'
  #  -> os.edition  = 'Professional'
  #  -> os.vendor   = 'Microsoft'
  #  -> os.version  = 'SP3'
  #  -> os.language = 'English'
  #  -> os.arch     = 'x86'
  #
  # These rules are then mapped to the MDM::Host attributes below:
  #   * os_name     - Maps to a normalized os.product key
  #   * os_flavor   - Maps to a normalized os.edition key
  #   * os_sp       - Maps to a normalized os.version key (soon os_version)
  #   * os_lang     - Maps to a normalized os.language key
  #   * arch        - Maps to a normalized os.arch key
  #
  # Additional rules include the following mappings:
  #   * name        - Maps to the host.name key
  #   * mac         - Maps to the host.mac key
  #
  # The following keys are not mapped to MDM::Host at this time (but should be):
  #   * os.vendor 
  #
  # In order to execute these rules, this module is responsible for mapping various
  # fingerprint sources to MDM::Host values. This requires some ugly glue code to
  # account for differences between each supported input (external scanners), the
  # Recog gem and associated databases, and how Metasploit itself likes to handle
  # these values. Getting a mapping wrong is often harmless, but can impact the
  # automatic targetting capabilities of certain exploit modules. 
  #
  # In other words, this is a best-effort attempt to rational multiple competing
  # sources of information about a host and come up with the values representing
  # a normalized assessment of the system. The use of Recog and multiple scanner
  # fingerprints can result in a comprehensive (and confident) identification of
  # the remote operating system and associated services.
  #
  # Historically, there are direct conflicts between certain Metasploit modules,
  # certain scanners, and external fingerprint databases in terms of how a 
  # particular OS and patch level is represented. This module attempts to fix
  # what it can and serve as documentation and live workarounds for the rest.
  # 
  # Examples of known conflicts that are still in progress:
  #
  # * Metasploit defines an OS constant of 'win'/'windows' as Microsoft Windows
  #   -> Scanner modules report a mix of 'Microsoft Windows' and 'Windows'
  #   -> Nearly all exploit modules reference 'Windows <Release> SP<Version>'
  #   -> Nmap (and other scanners) also prefix the vendor before Windows
  #
  # * Windows service packs represented as 'Service Pack X' or 'SPX'
  #   -> The preferred form is to set os.version to 'SPX'
  #   -> Many external scanners & Recog prefer 'Service Pack X'
  # 
  # * Apple Mac OS X, Cisco IOS, IBM AIX, Ubuntu Linux, all reported with vendor prefix
  #   -> The preferred form is to remove the vendor from os.product
  #   -> MDM::Host currently has no vendor field, so this information is lost today
  #   -> Many scanners report leading vendor strings and require normalization
  #
  #  * The os_flavor field is used in contradictory ways across Metasploit
  #   -> The preferred form is to be a 'display only' field
  #   -> Some Recog fingerprints still append the edition to os.product
  #   -> Many scanners report the edition as a trailing suffix to os.product
  #


  # 
  # Maintenance:
  #
  # 1. Ensure that the latest Recog gem is present and installed
  # 2. For new operating system releases, update relevant sections
  #    a) Windows releases will require updates to a few methods
  #      i) parse_windows_os_str()
  #     ii) normalize_nmap_fingerprint()
  #    iii) normalize_nexpose_fingerprint()
  #     iv) Other scanner normalizers 
  #    b) Mobile operating systems are minimally recognized
  #

  # TODO: Handle OS icon incompatiblities with new fingerprint names
  #       Note that VMWare ESX(i) was special cased before as well, make sure it still works
  #        Example: Cisco IOS -> IOS breaks the icon mapping in MSP/MSCE of /cisco/
  #        Example: Ubuntu Linux -> Linux breaks the distro selection
  #       The real solution is to add os_vendor and take this into account for icons
  #
  # TODO: Determine how smb.fingerprint will report version & language information
  # TODO: Implement rspec coverage for normalize_os()
  # TODO: Implement smb.generic fingerprint database (replace parse_windows_os_str?)
  # TODO: Implement smb.fingerprint changes ( data[:native_os] )
  # TODO: Correct inconsistencies in os_name use by removing the vendor string (Microsoft Windows -> Windows)
  #       This applies to MSF core and a handful of modules, not to mention some Recog fingerprints.
  # TODO: Rename host.os_sp to host.os_version
  # TODO: Add host.os_vendor
  # TODO: Add host.os_confidence
  # TODO: Add host.domain
  #


  #
  # Normalize the operating system fingerprints provided by various scanners
  # (nmap, nexpose, retina, nessus, metasploit modules, and more!)
  #
  # These are stored as notes (instead of directly in the os_* fields)
  # specifically for this purpose.
  #
  def normalize_os
    host   = self
    matches = []

    #
    # The goal is to infer as much as we can about the OS of the device and
    # the various services offered using the Recog gem and some glue logic 
    # to determine the best weights. This method can result in changes to
    # the recorded host.os_name, host.os_flavor, host.os_sp, host.os_lang,
    # host.purpose, host.name, host.arch, and the service details.
    #

    #
    # These rules define the relationship between fingerprint note keys
    # and specific Recog databases for detailed matching. Notes that do
    # not match a rule are passed to the generic matcher.
    #
    fingerprint_note_match_keys = {
      'smb.fingerprint'  => {
        :native_os               => [ 'smb.native_os' ],
      },
      'http.fingerprint' => {
        :header_server           => [ 'http_header.server', 'apache_os' ],
        :header_set_cookie       => [ 'http_header.cookie' ],
        :header_www_authenticate => [ 'http_header.wwwauth' ],
      # TODO: Candidates for future Recog support
      # :content                 => 'http_body'
      # :code                    => 'http_response_code'
      # :message                 => 'http_response_message'
      }
    }

    # Note that we're already restricting the query to this host by using
    # host.notes instead of Note, so don't need a host_id in the
    # conditions.
    fingerprintable_notes = self.notes.where("ntype like '%%fingerprint'")
    fingerprintable_notes.each do |fp|

      # Skip notes that re missing the correct structure or have been blacklisted
      next if not validate_fingerprint_data(fp)

      # Look for a specific Recog database for this type and data key
      if fingerprint_note_match_keys.has_key?( fp.ntype )
        fingerprint_note_match_keys[ fp.ntype ].each_pair do |k,rdbs|
          if fp.data.has_key?(k)
            rdbs.each do |rdb|
              res = Recog::Nizer.match(rdb, fp.data[k])
              matches << res if res
            end
          end
        end
      else 
        # Add all generic match results to the overall match array
        normalize_scanner_fp(fp).each do |m|
          matches << m
        end
      end

    end


    #
    # We assume that the service.info field contains certain types of probe 
    # replies and associate these with one or more Recog databases. The mapping
    # of service.name to a specific database only fits into so many places and
    # MDM currently serves that role.
    #

    service_match_keys = {
      # TODO: Implement smb.generic fingerprint database
      # 'smb'     => [ 'smb.generic' ], # Distinct from smb.fingerprint, use os.certainty to choose best match
      # 'netbios' => [ 'smb.generic' ], # Distinct from smb.fingerprint, use os.certainty to choose best match
      
      'ssh'     => [ 'ssh.banner' ],
      'http'    => [ 'http_header.server', 'apache_os'], # The 'Apache' fingerprints try to infer OS/distribution from the extra information in the Server header
      'https'   => [ 'http_header.server', 'apache_os'], # XXX: verify vmware esx(i) case on https (TODO: normalize https to http, track SSL elsewhere, such as a new set of fields)
      'snmp'    => [ 'snmp.sys_description' ],
      'telnet'  => [ 'telnet.banner' ],
      'smtp'    => [ 'smtp.banner' ],
      'imap'    => [ 'imap4.banner' ],  # Metasploit reports 143/993 as imap (TODO: normalize imap to imap4)
      'pop3'    => [ 'pop3.banner' ],   # Metasploit reports 110/995 as pop3
      'nntp'    => [ 'nntp.banner' ],
      'ftp'     => [ 'ftp.banner' ],
      'ssdp'    => [ 'ssdp_header.server' ]
    }


    # XXX: This hack solves the memory leak generated by self.services.each {}    
    fingerprintable_services = self.services.where("name is not null and name != '' and info is not null and info != ''")
    fingerprintable_services.each do |s|
      next unless service_match_keys.has_key?(s.name)
      service_match_keys[s.name].each do |rdb|
        res = Recog::Nizer.match(rdb, s.info)
        matches << res if res 
       end
    end

    # Normalize matches for consistency during the ranking phase
    matches = matches.map{ |m| normalize_match(m) }

    # Calculate the best OS match based on fingerprint hits
    match = Recog::Nizer.best_os_match(matches)

    # Merge and normalize the best match to the host object
    apply_match_to_host(match) if match 

    # Handle cases where the flavor contains the base name (legacy parsing, etc)
    # TODO: Remove this once we are sure it is no longer needed
    if host.os_name and host.os_flavor and host.os_flavor.index(host.os_name)
      host.os_flavor = host.os_flavor.gsub(host.os_name, '').strip
    end

    # Set some sane defaults if needed
    host.os_name ||= 'Unknown'
    host.purpose ||= 'device'

    host.save if host.changed?
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
  # Normalize matches in order to handle inconsistencies between fingerprint
  # sources and our desired usage in Metasploit. This amounts to yet more
  # duct tape, but the situation should improve as the fingerprint sources
  # are updated and enhanced. In the future, this method will no longer
  # be needed (or at least, doing less and less work)
  #
  def normalize_match(m)
    # Normalize os.version strings containing 'Service Pack X' to just 'SPX'
    if m['os.version'] and m['os.version'].index('Service Pack ') == 0
      m['os.version'] = m['os.version'].gsub(/Service Pack /, 'SP')
    end

    if m['os.product']

      # Normalize Apple Mac OS X to just Mac OS X
      if m['os.product'] =~ /^Apple Mac/
        m['os.product']  = m['os.product'].gsub(/Apple Mac/, 'Mac')
        m['os.vendor'] ||= 'Apple'
      end

      # Normalize Microsoft Windows to just Windows to catch any stragglers
      if m['os.product'] =~ /^Microsoft Windows/
        m['os.product']  = m['os.product'].gsub(/Microsoft Windows/, 'Windows')
        m['os.vendor'] ||= 'Microsoft'
      end

      # Normalize Windows Server to just Windows to match Metasploit target names
      if m['os.product'] =~ /^Windows Server/
        m['os.product'] = m['os.product'].gsub(/Windows Server/, 'Windows')
      end
    end 

    m
  end

  #
  # Examine the assertations of the merged best match and map these 
  # back to fields of MDM::Host. Take particular care not to leave
  # related fields (os_*) in a conflicting state, leverage existing
  # values where possible, and use the most confident values we have.
  #
  def apply_match_to_host(match)
    host = self

    # These values in a match always override the current value unless
    # the host attribute has been explicitly locked by the user

    if match.has_key?('host.mac') and ! host.attribute_locked?(:mac)
      host.mac = sanitize(match['host.mac'])
    end

    if match.has_key?('host.name') and ! host.attribute_locked?(:name)
      host.name = sanitize(match['host.name'])
    end

    # Select the os architecture if available
    if match.has_key?('os.arch') and ! host.attribute_locked?(:arch)
      host.arch = sanitize(match['os.arch'])
    end

    # Guess the purpose using some basic heuristics
    if ! host.attribute_locked?(:purpose)
      host.purpose = guess_purpose_from_match(match)
    end

    #
    # Map match fields from Recog fingerprint style to Metasploit style
    # 

    # os.build:                 Examples: 9001, 2600, 7602
    # os.device:                Examples: General, ADSL Modem, Broadband router, Cable Modem, Camera, Copier, CSU/DSU
    # os.edition:               Examples: Web, Storage, HPC, MultiPoint, Enterprise, Home, Starter, Professional
    # os.family:                Examples: Windows, Linux, Solaris, NetWare, ProCurve, Mac OS X, HP-UX, AIX
    # os.product:               Examples: Windows, Linux, Windows Server 2008 R2, Windows XP, Enterprise Linux, NEO Tape Library
    # os.vendor:                Examples: Microsoft, HP, IBM, Sun, 3Com, Ricoh, Novell, Ubuntu, Apple, Cisco, Xerox
    # os.version:               Examples: SP1, SP2, 6.5 SP3 CPR, 10.04, 8.04, 12.10, 4.0, 6.1, 8.5
    # os.language:              Examples: English, Arabic, German
    # linux.kernel.version:     Examples: 2.6.32

    # Metasploit currently ignores os.build, os.device, and os.vendor as separate fields.

    # Select the OS name from os.name, fall back to os.family
    if ! host.attribute_locked?(:os_name)
      # Try to fill this value from os.product first if it exists
      if match.has_key?('os.product')
        host.os_name = sanitize(match['os.product'])
      else
        # Fall back to os.family otherwise, if available
        if match.has_key?('os.family')
          host.os_name = sanitize(match['os.family'])
        end
      end
    end

    # Select the flavor from os.edition if available
    if match.has_key?('os.edition') and ! host.attribute_locked?(:os_flavor)
      host.os_flavor = sanitize(match['os.edition'])
    end

    # Select an OS version as os.version, fall back to linux.kernel.version
    if ! host.attribute_locked?(:os_sp)
      if match['os.version']
        host.os_sp = sanitize(match['os.version'])
      else
        if match['linux.kernel.version']
          host.os_sp = sanitize(match['linux.kernel.version'])
        end
      end
    end

    # Select the os language if available
    if match.has_key?('os.language') and ! host.attribute_locked?(:os_lang)
      host.os_lang = sanitize(match['os.language'])
    end

  end

  #
  # Loosely guess the purpose of a device based on available
  # match values. In the future, also take into account the
  # exposed services and rename to guess_purpose_with_match()
  #
  def guess_purpose_from_match(match)
    # Create a string based on all match values
    pstr = match.values.join(' ').downcase

    # Loosely map keywords to specific purposes
    case pstr
    when /windows server|windows (nt|20)/
      'server'
    when /windows (xp|vista|[78])/
      'client'
    when /printer|print server/
      'printer'
    when /router/
      'router'
    when /firewall/
      'firewall'
    when /linux/
      'server'
    else
      'device'
    end
  end

  # Ensure that the host attribute is using ascii safe text
  # and escapes any other byte value.
  def sanitize(text)
    Rex::Text.ascii_safe_hex(text)
  end

  #
  # Normalize data from Meterpreter's client.sys.config.sysinfo()
  #
  def normalize_session_fingerprint(data)
    ret = {}
    case data[:os]
      when /Windows/
        ret.update(parse_windows_os_str(data[:os]))
      when /Linux (\d+\.\d+\.\d+\S*)\s* \((\w*)\)/
        ret['os.product'] = "Linux"
        ret['host.name']  = data[:name]
        ret['os.version'] = $1
        ret['os.arch']    = get_arch_from_string($2)
      else
        ret['os.product'] = data[:os]
    end
    ret['os.arch'] = data[:arch] if data[:arch]
    ret['host.name'] = data[:name] if data[:name] 
    [ ret ]
  end

  #
  # Normalize data from Nmap fingerprints
  #
  def normalize_nmap_fingerprint(data)
    ret = {}
    # :os_vendor=>"Microsoft" :os_family=>"Windows" :os_version=>"2000" :os_accuracy=>"94"
    ret['os.certainty'] = ( data[:os_accuracy].to_f / 100.0 ).to_s if data[:os_accuracy]
    if (data[:os_vendor] == data[:os_family])
      ret['os.product'] = data[:os_family]
    else
      ret['os.product'] = data[:os_family]
      ret['os.vendor'] = data[:os_vendor]
    end

    # Nmap places the type of Windows (XP, 7, etc) into the version field
    if ret['os.product'] == 'Windows' and data[:os_version]
      ret['os.product'] = ret['os.product'] + ' ' + data[:os_version].to_s
    else
      ret['os.version'] = data[:os_version]
    end

    ret['host.name'] = data[:hostname] if data[:hostname]

    [ ret ]  
  end

  #
  # Normalize data from MBSA fingerprints
  #
  def normalize_mbsa_fingerprint(data)
    ret = {}    
    # :os_match=>"Microsoft Windows Vista SP0 or SP1, Server 2008, or Windows 7 Ultimate (build 7000)"
    #    :os_vendor=>"Microsoft" :os_family=>"Windows" :os_version=>"7" :os_accuracy=>"100"
    ret['os.certainty'] = ( data[:os_accuracy].to_f / 100.0 ).to_s if data[:os_accuracy]
    ret['os.family']    = data[:os_family] if data[:os_family]
    ret['os.vendor']    = data[:os_vendor] if data[:os_vendor]

    if data[:os_family] and data[:os_version]
      ret['os.product'] = data[:os_family] + " " + data[:os_version]
    end

    ret['host.name'] = data[:hostname] if data[:hostname]

    [ ret ]
  end


  #
  # Normalize data from Nexpose fingerprints
  #
  def normalize_nexpose_fingerprint(data)
    ret = {}    
    # :family=>"Windows" :certainty=>"0.85" :vendor=>"Microsoft" :product=>"Windows 7 Ultimate Edition"
    # :family=>"Windows" :certainty=>"0.67" :vendor=>"Microsoft" :arch=>"x86" :product=>'Windows 7' :version=>'SP1'
    # :family=>"Linux" :certainty=>"0.64" :vendor=>"Linux" :product=>"Linux"
    # :family=>"Linux" :certainty=>"0.80" :vendor=>"Ubuntu" :product=>"Linux"
    # :family=>"IOS" :certainty=>"0.80" :vendor=>"Cisco" :product=>"IOS"
    # :family=>"embedded" :certainty=>"0.61" :vendor=>"Linksys" :product=>"embedded"

    ret['os.certainty'] = data[:certainty] if data[:certainty]
    ret['os.family']    = data[:family]    if data[:family]
    ret['os.vendor']    = data[:vendor]    if data[:vendor]

    case data[:product]
    when /^Windows/
      
      # TODO: Verify Windows CE and Windows 8 RT fingerprints
      # Translate the version into the representation we want

      case data[:version].to_s
      
      # These variants are normalized to just 'Windows <Version>'
      when "NT", "2000", "95", "ME", "XP", "Vista", "7", "8", "8.1"
        ret['os.product'] = "Windows #{data[:version]}"
      
      # Service pack in the version field should be recognized
      when /^SP\d+/, /^Service Pack \d+/
        ret['os.product'] = data[:product]
        ret['os.version'] = data[:version]

      # No version means the version is part of the product already
      when nil, ''
        ret['os.product'] = data[:product]

      # Otherwise, we assume a Server version of Windows
      else
        ret['os.product'] = "Windows Server #{data[:version]}"
      end

      # Extract the edition string if it is present 
      if data[:product] =~ /(XP|Vista|\d+) (\w+|\w+ \w+|\w+ \w+ \w+) Edition/
        ret['os.edition'] = $2
      end

    when nil, 'embedded'
      # Use the family or vendor name when the product is empty or 'embedded'
      ret['os.product']   = data[:family] unless data[:family] == 'embedded'
      ret['os.product'] ||= data[:vendor]
      ret['os.version']   = data[:version] if data[:version]
    else
      # Default to using the product name reported by Nexpose
      ret['os.product'] = data[:product] if data[:product]
    end

    ret['os.arch'] = get_arch_from_string(data[:arch]) if data[:arch]
    ret['os.arch'] ||= get_arch_from_string(data[:desc]) if data[:desc]

    [ ret ]
  end


  #
  # Normalize data from Retina fingerprints
  #
  def normalize_retina_fingerprint(data)
    ret = {}
    # :os=>"Windows Server 2003 (X64), Service Pack 2"
    case data[:os]
      when /Windows/
        ret.update(parse_windows_os_str(data[:os]))
      else
        # No idea what this looks like if it isn't windows.  Just store
        # the whole thing and hope for the best.
        # TODO: Add examples of non-Windows results
        ret['os.product'] = data[:os] if data[:os]
    end
    [ ret ]
  end


  #
  # Normalize data from Nessus fingerprints
  #
  def normalize_nessus_fingerprint(data)
    ret = {}   
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
      ret['os.certainty'] = 0.5
    else
      ret['os.certainty'] = 0.8
    end

    # Since there is no confidence associated with them, the best we
    # can do is just take the first one.
    case oses.first
      when /Windows/
        ret.update(parse_windows_os_str(data[:os]))

      when /(2\.[46]\.\d+[-a-zA-Z0-9]+)/
        # Linux kernel version
        ret['os.product'] = "Linux"
        ret['os.version'] = $1
      when /(.*)?((\d+\.)+\d+)$/
        # Then we don't necessarily know what the os is, but this
        # fingerprint has some version information at the end, pull it
        # off.
        # When Nessus doesn't know what kind of linux it has, it gives an os like
        #  "Linux Kernel 2.6"
        # The "Kernel" string is useless, so cut it off.
        ret['os.product'] = $1.gsub("Kernel", '').strip
        ret['os.version'] = $2
      else
        # TODO: Return each OS guess as a separate match
        ret['os.product'] = oses.first
    end

    ret['host.name'] = data[:hname] if data[:hname]
    [ ret ] 
  end

  #
  # Normalize data from Qualys fingerprints
  #
  def normalize_qualys_fingerprint(data)
    ret = {}
    # :os=>"Microsoft Windows 2000"
    # :os=>"Windows 2003"
    # :os=>"Microsoft Windows XP Professional SP3"
    # :os=>"Ubuntu Linux"
    # :os=>"Cisco IOS 12.0(3)T3"
    # :os=>"Red-Hat Linux 6.0"
    case data[:os]
      when /Windows/
        ret.update(parse_windows_os_str(data[:os]))

      when /^(Cisco) (IOS) (\d+[^\s]+)/
        ret['os.product'] = $2
        ret['os.vendor']  = $1
        ret['os.version'] = $3

      when /^([^\s]+) (Linux)(.*)/
        ret['os.product'] = $2
        ret['os.vendor'] = $1
        
        ver = $3.to_s.strip.split(/\s+/).first
        if ver =~ /^\d+\./
          ret['os.version'] = ver
        end

      else
        parts = data[:os].split(/\s+/, 3)
        ret['os.product'] = "Unknown"
        ret['os.product'] = parts[0] if parts[0]
        ret['os.product'] << " " + parts[1] if parts[1]
        ret['os.version'] = parts[2] if parts[2]
    end
    [ ret ]
  end
  
  #
  # Normalize data from FusionVM fingerprints
  #
  def normalize_fusionvm_fingerprint(data)
    ret = {}
    case data[:os]
      when /Windows/
        ret.update(parse_windows_os_str(data[:os]))
      when /Linux ([^[:space:]]*) ([^[:space:]]*) .* (\(.*\))/
        ret['os.product'] = "Linux"
        ret['host.name']  = $1
        ret['os.version'] = $2
        ret['os.arch']    = get_arch_from_string($3)
      else
        ret['os.product'] = data[:os]
    end
    ret['os.arch'] = data[:arch] if data[:arch]
    ret['host.name'] = data[:name] if data[:name]
    [ ret ]
  end

  #
  # Normalize data from generic fingerprints
  #
  def normalize_generic_fingerprint(data)
    ret = {}
    ret['os.product'] = data[:os_name] || data[:os] || data[:os_fingerprint] || "Unknown"
    ret['os.arch'] = data[:os_arch] if data[:os_arch]
    ret['os.certainty'] = data[:os_certainty] || 0.5
    [ ret ]
  end

  #
  # Convert a host.os.*_fingerprint Note into a hash containing 'os.*' and 'host.*' fields
  #
  # Also includes a os.certainty which is a float from 0 - 1.00 indicating the
  # scanner's confidence in its fingerprint.  If the particular scanner does
  # not provide such information, default to 0.80.
  #
  def normalize_scanner_fp(fp)
    hits = []

    return hits if not validate_fingerprint_data(fp)
    
    case fp.ntype
    when /^host\.os\.(.*_fingerprint)$/
      pname = $1
      pmeth = 'normalize_' + pname
      if self.respond_to?(pmeth)
        hits = self.send(pmeth, fp.data)
      else 
        hits = normalize_generic_fingerprint(fp.data)
      end
    end
    hits.each {|hit| hit['os.certainty'] ||= 0.80}
    hits
  end

  #
  # Take a windows version string and return a hash with fields suitable for
  # Host this object's version fields. This is used as a fall-back to parse
  # external fingerprints and should eventually be replaced by per-source
  # mappings.
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

    ret['os.product'] = "Windows"
    arch = get_arch_from_string(str)
    ret['os.arch'] = arch if arch

    if str =~ /(Service Pack|SP) ?(\d+)/
      ret['os.version']  = "SP#{$2}"
    end

    # Flavor
    case str
      when /\.NET Server|2003/
        ret['os.product'] << ' Server 2003'
      when /(2008|2012)/
        ret['os.product'] << ' Server ' + $1
      when /(2000)/
        ret['os.product'] << ' Server ' + $1
      when /(Vista|7|8\.1|8)/
        ret['os.product'] << ' ' + $1
      else
        # If we couldn't pull out anything specific for the flavor, just cut
        # off the stuff we know for sure isn't it and hope for the best
        ret['os.product'] = (ret['os.product'] + ' ' + str.gsub(/(Microsoft )|(Windows )|(Service Pack|SP) ?(\d+)/, '').strip).strip
    end

    if str =~ /(\d+|\d+\.\d+) (\w+|\w+ \w+|\w+ \w+ \w+) Edition/
      ret['os.edition'] = $2
    else
      if str =~ /(Professional|Enterprise|Pro|Home|Start|Datacenter|Web|Storage|MultiPoint)/
        ret['os.edition'] = $1
      end
    end

    ret
  end

  #
  # Return a normalized architecture based on patterns in the input string.
  # This will identify things like sparc, powerpc, x86_x64, and i686
  #
  def get_arch_from_string(str)
    res = Recog::Nizer.match("architecture", str)
    return unless (res and res['os.arch'])
    res['os.arch']
  end
end




# Legacy matching rules, replaced by Recog and above logic
=begin
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
=end