# A system with an {#address IP address} on the network that has been discovered in some way.
class Mdm::Host < ActiveRecord::Base
  include Mdm::Host::OperatingSystemNormalization

  #
  # CONSTANTS
  #

  # Either the CPU architecture for native code or the programming language name for exploits that run code in the
  # programming language's  virtual machine.
  ARCHITECTURES = [
      'armbe',
      'armle',
      'cbea',
      'cbea64',
      'cmd',
      'java',
      'mips',
      'mipsbe',
      'mipsle',
      'php',
      'ppc',
      'ppc64',
      'ruby',
      'sparc',
      'tty',
      # To be used for compatability with 'X86_64'
      'x64',
      'x86',
      'x86_64'
  ]

  # Fields searched for the search scope
  SEARCH_FIELDS = [
      'address::text',
      'comments',
      'mac',
      'name',
      'os_flavor',
      'os_name',
      'os_sp',
      'purpose'
  ]

  # Valid values for {#state}.
  STATES = [
      'alive',
      'down',
      'unknown'
  ]

  #
  # Associations
  #

  # @!attribute [rw] exploit_attempts
  #   Attempts to run exploits against this host.
  #
  #   @return [Array<Mdm::ExploitAttempt]
  has_many :exploit_attempts,
           :class_name => 'Mdm::ExploitAttempt',
           :dependent => :destroy

  # @!attribute [rw] exploited_hosts
  #   @todo https://www.pivotaltracker.com/story/show/48993731
  #   @return [Array<Mdm::ExploitedHost>]
  has_many :exploited_hosts, :class_name => 'Mdm::ExploitedHost', :dependent => :destroy

  # @!attribute [rw] host_details
  #   @return [Array<Mdm::HostDetail>]
  has_many :host_details, :class_name => 'Mdm::HostDetail', :dependent => :destroy

  # @!attribute [rw] hosts_tags
  #   A join model between {Mdm::Tag} and {Mdm::Host}.  Use {#tags} to get the actual {Mdm::Tag Mdm::Tags} on this host.
  #   {#hosts_tags} are cleaned up in a before_destroy: {#cleanup_tags}.
  #
  #   @todo https://www.pivotaltracker.com/story/show/48923201
  #   @return [Array<Mdm::HostTag>]
  has_many :hosts_tags, :class_name => 'Mdm::HostTag'

  # @!attribute [rw] loots
  #   Loot gathered from the host with {Mdm::Loot#created_at newest loot} first.
  #
  #   @todo https://www.pivotaltracker.com/story/show/48991525
  #   @return [Array<Mdm::Loot>]
  has_many :loots, :class_name => 'Mdm::Loot', :dependent => :destroy, :order => 'loots.created_at DESC'

  # @!attribute [rw] notes
  #   Notes about the host entered by a user with {Mdm::Note#created_at oldest notes} first.
  #
  #   @return [Array<Mdm::Note>]
  has_many :notes, :class_name => 'Mdm::Note', :dependent => :delete_all, :order => 'notes.created_at'

  # @!attribute [rw] services
  #   The services running on {Mdm::Service#port ports} on the host with services ordered by {Mdm::Service#port port}
  #   and {Mdm::Service#proto protocol}.
  #
  #   @return [Array<Mdm::Service>]
  has_many :services, :class_name => 'Mdm::Service', :dependent => :destroy, :order => 'services.port, services.proto'

  # @!attribute [rw] sessions
  #   Sessions that are open or previously were open on the host ordered by {Mdm::Session#opened_at when the session was
  #   opened}
  #
  #   @return [Array<Mdm::Session]
  has_many :sessions, :class_name => 'Mdm::Session', :dependent => :destroy, :order => 'sessions.opened_at'

  # @!attribute [rw] vulns
  #   Vulnerabilities found on the host.
  #
  #   @return [Array<Mdm::Vuln>]
  has_many :vulns, :class_name => 'Mdm::Vuln', :dependent => :delete_all

  # @!attribute [rw] workspace
  #   The workspace in which this host was found.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace, :class_name => 'Mdm::Workspace'

  #
  # Through host_tags
  #

  # @!attribute [r] tags
  #   The tags on this host.  Tags are used to filter hosts.
  #
  #   @return [Array<Mdm::Tag>]
  #   @see #hosts_tags
  has_many :tags, :class_name => 'Mdm::Tag', :through => :hosts_tags

  #
  # Through services
  #

  # @!attribute [r] creds
  #   Credentials captured from {#services}.
  #
  #   @return [Array<Mdm::Cred>]
  #   @see #services
  has_many :creds, :class_name => 'Mdm::Cred', :through => :services

  # @!attribute [r] service_notes
  #   {Mdm::Note Notes} about {#services} running on this host.
  #
  #   @return [Array<Mdm::Note>]
  #   @see #services
  has_many :service_notes, :class_name => 'Mdm::Note', :through => :services

  # @!attribute [r] web_sites
  #   {Mdm::WebSite Web sites} running on top of {#services} on this host.
  #
  #   @return [Array<Mdm::WebSite>]
  #   @see services
  has_many :web_sites, :class_name => 'Mdm::WebSite', :through => :services

	#
	# Through vulns
	#

  # @!attribute [r] vuln_refs
  #   Join model between {#vulns} and {#refs}.  Use either of those asssociations instead of this join model.
  #
  #   @todo https://www.pivotaltracker.com/story/show/49004623
  #   @return [Array<Mdm::VulnRef>]
  #   @see #refs
  #   @see #vulns
	has_many :vuln_refs, :class_name => 'Mdm::VulnRef', :source => :vulns_refs, :through => :vulns

	#
	# Through vuln_refs
	#

  # @!attribute [r] refs
  #   External references, such as CVE, to vulnerabilities found on this host.
  #
  #   @return [Array<Mdm::Ref>]
  #   @see #vuln_refs
	has_many :refs, :class_name => 'Mdm::Ref', :through => :vuln_refs

	#
	# Through refs
	#

  # @!attribute [r] module_refs
  #   {Mdm::Module::Ref References for modules} for {Mdm::Ref references for vulnerabilities}.
  #
  #   @return [Array<Mdm::Module::Ref>]
	has_many :module_refs, :class_name => 'Mdm::Module::Ref', :through => :refs

	#
	# Through module_refs
	#

  # @!attribute [r] module_details
  #   {Mdm::Module::Detail Details about modules} that were used to find {#vulns vulnerabilities} on this host.
  #
  #   @return [Array<Mdm::Module::Detail]
	has_many :module_details,
           :class_name => 'Mdm::Module::Detail',
           :source =>:detail,
           :through => :module_refs,
           :uniq => true

  #
  # Attributes
  #

  # @!attribute [rw] address
  #   The IP address of this host.
  #
  #   @return [String]

  # @!attribute [rw] arch
  #   The architecture of the host's CPU OR the programming language for virtual machine programming language like
  #   Ruby, PHP, and Java.
  #
  #   @return [String] an element of {ARCHITECTURES}

  # @!attribute [rw] comm
  #   @todo https://www.pivotaltracker.com/story/show/49722411
  #
  #   @return [String]

  # @!attribute [rw] comments
  #   User supplied comments about host.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this host was created in the database.
  #
  #   @return [DateTime]

  # @!attribute [rw] cred_count
  #   Counter cache for {#creds}.
  #
  #   @return [Integer]

  # @!attribute [rw] exploit_attempt_count
  #   Counter cache for {#exploit_attempts}.
  #
  #   @return [Integer]

  # @!attribute [rw] host_detail_count
  #   Counter cache for {#host_details}.
  #
  #   @return [Integer]

  # @!attribute [rw] info
  #   Information about this host gathered from the host.
  #
  #   @return [String]

  # @!attribute [rw] mac
  #   The MAC address of this host.
  #
  #   @return [String]
  #   @see http://en.wikipedia.org/wiki/Mac_address

  # @!attribute [rw] name
  #   The name of the host.  If the host name is not available, then it will just be the IP address.
  #
  #   @return [String]

  # @!attribute [rw] note_count
  #   Counter cache for {#notes}.
  #
  #   @return [Integer]

  # @!attribute [rw] os_flavor
  #   The flavor of {#os_name}.
  #
  #   @example Windows XP
  #     host.os_name = 'Microsoft Windows'
  #     host.os_flavor = 'XP'
  #
  #   @return [String]

  # @!attribute [rw] os_lang
  #   Free-form language of operating system.  Usually either spelled out like 'English' or an
  #   {http://en.wikipedia.org/wiki/IETF_language_tag IETF language tag} like 'en' or 'en-US'.
  #
  #   @return [String]

  # @!attribute [rw] os_name
  #  The name of the operating system.
  #
  #  @return [String]

  # @!attribute [rw] os_sp
  #   The service pack of the {#os_flavor} of the {#os_name}.
  #
  #   @example Windows XP SP2
  #     host.os_name = 'Microsoft Windows'
  #     host.os_flavor = 'XP'
  #     host.os_sp = 'SP2'
  #
  #   @return [String]

  # @!attribute [rw] purpose
  #   The purpose of the host on the network, such as 'client' or 'firewall'.
  #
  #   @return [String]

  # @!attribute [rw] scope
  #   Interface identifier for link-local IPv6
  #
  #   @return [String]
  #   @see http://en.wikipedia.org/wiki/IPv6_address#Link-local_addresses_and_zone_indices

  # @!attribute [rw] service_count
  #   Counter cache for {#services}.
  #
  #   @return [Integer]

  # @!attribute [rw] state
  #   Whether the host is alive, down, or in an unknown state.
  #
  #   @return [String] element of {STATES}.

  # @!attribute [rw] updated_at
  #   The last time this host was updated in the database.
  #
  #   @return [DateTime]

  # @!attribute [rw] virtual_host
  #   The name of the virtual machine host software, such as 'VMWare', 'QEMU', 'XEN', etc.
  #
  #   @return [String]

  # @!attribute [rw] vuln_count
  #   Counter cache for {#vulns}.
  #
  #   @return [Integer]

  #
  # Callbacks
  #

  before_destroy :cleanup_tags

  #
  # Nested Attributes
  # @note Must be declared after relations being referenced.
  #

  accepts_nested_attributes_for :services, :reject_if => lambda { |s| s[:port].blank? }, :allow_destroy => true

  #
  # Validations
  #

  validates :address,
            :exclusion => {
                :in => ['127.0.0.1']
            },
            :ip_format => true,
            :presence => true,
            :uniqueness => {
                :scope => :workspace_id,
                :unless => :ip_address_invalid?
            }
  validates :arch,
            :allow_nil => true,
            :inclusion => {
                :in => ARCHITECTURES
            }
  validates :state,
            :allow_nil => true,
            :inclusion => {
                :in => STATES
            }
  validates :workspace, :presence => true

  #
  # Scopes
  #

  scope :alive, where({'hosts.state' => 'alive'})
  scope :flagged, where('notes.critical = true AND notes.seen = false').includes(:notes)
  scope :search,
        lambda { |*args|
          # @todo replace with AREL
          terms = SEARCH_FIELDS.collect { |field|
            "#{field} ILIKE ?"
          }
          disjunction = terms.join(' OR ')
          formatted_parameter = "%#{args[0]}%"
          parameters = [formatted_parameter] * SEARCH_FIELDS.length
          conditions = [disjunction] + parameters

          {
              :conditions => conditions
          }
        }
  scope :tag_search,
        lambda { |*args| where("tags.name" => args[0]).includes(:tags) }

  # Returns whether 'host.updated.<attr>' {#notes note} is {Mdm::Note#data locked}.
  #
  # @return [true] if Mdm::Note with 'host.updated.<attr>' as {Mdm::Note#name} exists and data[:locked] is `true`.
  # @return [false] otherwise.
  def attribute_locked?(attr)
    n = notes.find_by_ntype("host.updated.#{attr}")
    n && n.data[:locked]
  end

  # Destroys any {Mdm::Tag Mdm::Tags} that will have no {Mdm::Tag#hosts} left after this host is deleted.
  #
  # @return [void]
  def cleanup_tags
    # No need to keep tags with no hosts
    tags.each do |tag|
      tag.destroy if tag.hosts == [self]
    end
    # Clean up association table records
    Mdm::HostTag.delete_all("host_id = #{self.id}")
  end

  # This is replicated by the IpAddressValidator class. Had to put it here as well to avoid
  # SQL errors when checking address uniqueness.
  #
  # @return [void]
  def ip_address_invalid?
    begin
      potential_ip = IPAddr.new(address)
      return true unless potential_ip.ipv4? || potential_ip.ipv6?
    rescue ArgumentError
      return true
    end
  end

  # Returns whether this host is a virtual machine.
  #
  # @return [true] unless {#virtual_host} is `nil`.
  # @return [false] otherwise.
  def is_vm?
    !!self.virtual_host
  end

  ActiveSupport.run_load_hooks(:mdm_host, self)
end

