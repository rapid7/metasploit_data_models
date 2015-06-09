# Workspace to separate different collections of {#hosts}.  Can be used to separate pentests against different networks
# or different clients as reports are normally generated against all records in a workspace.
class Mdm::Workspace < ActiveRecord::Base
  #
  # CONSTANTS
  #

  DEFAULT = 'default'

  #
  # Associations
  #

  # Automatic exploitation runs against this workspace.
  has_many :automatic_exploitation_runs,
           class_name: 'MetasploitDataModels::AutomaticExploitation::Run',
           inverse_of: :workspace

  # Automatic exploitation match sets generated against {#hosts} and {#services} in this workspace.
  has_many :automatic_exploitation_match_sets,
           class_name: 'MetasploitDataModels::AutomaticExploitation:MatchSet',
           inverse_of: :workspace

  # @deprecated Use `Mdm::Workspace#core_credentials` defined by `Metasploit::Credential::Engine` to get
  #   `Metasploit::Credential::Core`s gathered from this workspace's {#hosts} and {#services}.
  #
  # Creds gathered from this workspace's {#hosts} and {#services}.
  has_many :creds, :through => :services, :class_name => 'Mdm::Cred'

  # Events that occurred in this workspace.
  has_many :events, :class_name => 'Mdm::Event'

  # Hosts in this workspace.
  has_many :hosts, :dependent => :destroy, :class_name => 'Mdm::Host'

  # Listeners running for this workspace.
  has_many :listeners, :dependent => :destroy, :class_name => 'Mdm::Listener'

  # Notes about this workspace.
  has_many :notes, :class_name => 'Mdm::Note'

  # User that owns this workspace and has full permissions within this workspace even if they are not an
  # {Mdm::User#admin administrator}.
  belongs_to :owner, :class_name => 'Mdm::User', :foreign_key => 'owner_id'

  # Tasks run inside this workspace.
  has_many :tasks,
           -> { order('created_at DESC') },
           class_name: 'Mdm::Task',
           dependent: :destroy

  # Users that are allowed to use this workspace.  Does not necessarily include all users, as an {Mdm::User#admin
  # administrator} can access any workspace, even ones where they are not a member.
  has_and_belongs_to_many :users,
                          -> { uniq },
                          class_name: 'Mdm::User',
                          join_table: 'workspace_members'

  #
  # through: :hosts
  #

  # Social engineering campaign or browser autopwn clients from {#hosts} in this workspace.
  has_many :clients, :through => :hosts, :class_name => 'Mdm::Client'

  # Hosts exploited in this workspace.
  has_many :exploited_hosts, :through => :hosts, :class_name => 'Mdm::ExploitedHost'

  # Loot gathered from {#hosts} in this workspace.
  has_many :loots, :through => :hosts, :class_name => 'Mdm::Loot'

  # Services running on {#hosts} in this workspace.
  has_many :services,
           class_name: 'Mdm::Service',
           foreign_key: :service_id,
           through: :hosts

  # Vulnerabilities found on {#hosts} in this workspace.
  has_many :vulns, :through => :hosts, :class_name => 'Mdm::Vuln'

  # Sessions opened on {#hosts} in this workspace.
  has_many :sessions, :through => :hosts, :class_name => 'Mdm::Session'

  #
  # Attributes
  #

  # @!attribute boundary
  #   Comma separated list of IP ranges (in various formats) and IP addresses that users of this workspace are allowed
  #   to interact with if {#limit_to_network} is `true`.
  #
  #   @return [String]

  # @!attribute description
  #   Long description (beyond {#name}) that explains the purpose of this workspace.
  #
  #   @return [String]

  # @!attribute limit_to_network
  #   Whether {#boundary} is respected.
  #
  #   @return [false] do not limit interactions to {#boundary}.
  #   @return [true] limit interactions to {#boundary}.

  # @!attribute name
  #   Name of this workspace.
  #
  #   @return [String]

  # @!attribute created_at
  #   When this workspace was created.
  #
  #   @return [DateTime]

  # @!attribute updated_at
  #   The last time this workspace was updated.
  #
  #   @return [DateTime]

  #
  # Callbacks
  #

  before_save :normalize

  #
  # Validations
  #

  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :description, :length => {:maximum => 4096}
  validate :boundary_must_be_ip_range

  #
  # Instance Methods
  #

  # If {#limit_to_network} is disabled, this will always return `true`. Otherwise, return `true` only if all of the
  # given IPs are within the project {#boundary boundaries}.
  #
  # @param ips [String] IP range(s)
  # @return [true] if actions on ips are allowed.
  # @return [false] if actions are not allowed on ips.
  def allow_actions_on?(ips)
    return true unless limit_to_network
    return true unless boundary
    return true if boundary.empty?
    boundaries = Shellwords.split(boundary)
    return true if boundaries.empty? # It's okay if there is no boundary range after all
    given_range = Rex::Socket::RangeWalker.new(ips)
    return false unless given_range # Can't do things to nonexistant IPs
    allowed = false
    boundaries.each do |boundary_range|
      ok_range = Rex::Socket::RangeWalker.new(boundary)
      allowed  = true if ok_range.include_range? given_range
    end
    return allowed
  end

  # Validates that {#boundary} is {#valid_ip_or_range? a valid IP address or IP address range}.
  #
  # @return [void]
  def boundary_must_be_ip_range
    errors.add(:boundary, "must be a valid IP range") unless valid_ip_or_range?(boundary)
  end

  # @deprecated Use `Mdm::Workspace#credential_cores` when `Metasploit::Credential::Engine` is installed to get
  #    `Metasploit::Credential::Core`s.  Use `Mdm::Service#logins` when `Metasploit::Credential::Engine` is installed to
  #    get `Metasploit::Credential::Login`s.
  #
  # @return [ActiveRecord::Relation<Mdm::Cred>]
  def creds
    Mdm::Cred.find(
      :all,
      :include    => {:service => :host},
      :conditions => ["hosts.workspace_id = ?", self.id]
    )
  end

  # Returns default {Mdm::Workspace}.
  #
  # @return [Mdm::Workspace]
  def self.default
    where(name: DEFAULT).first_or_create
  end

  # Whether this is the {default} workspace.
  #
  # @return [true] if this is the {default} workspace.
  # @return [false] if this is not the {default} workspace.
  def default?
    name == DEFAULT
  end

  # @deprecated Use `workspace.credential_cores.each` when `Metasploit::Credential::Engine` is installed to enumerate
  #   `Metasploit::Credential::Core`s.  Use `service.logins.each` when `Metasploit::Credential::Engine` is installed to
  #   enumerate `Metasploit::Credential::Login`s.
  #
  # Enumerates each element of {#creds}.
  #
  # @yield [cred]
  # @yieldparam cred [Mdm::Cred] Cred associated with {#hosts a host} or {#services a service} in this workspace.
  # @yieldreturn [void]
  # @return [void]
  def each_cred(&block)
    creds.each do |cred|
      block.call(cred)
    end
  end

  # Enumerates each element of {#host_tags}.
  #
  # @yield [tag]
  # @yieldparam tag [Mdm::Tag] a tag on {#hosts}.
  # @yieldreturn [void]
  # @return [void]
  def each_host_tag(&block)
    host_tags.each do |host_tag|
      block.call(host_tag)
    end
  end

  # Tags on {#hosts}.
  #
  # @return [ActiveRecord::Relation<Mdm::Tag>]
  def host_tags
    Mdm::Tag.find(
      :all,
      :include    => :hosts,
      :conditions => ["hosts.workspace_id = ?", self.id]
    )
  end

  # Web forms found on {#web_sites}.
  #
  # @return [ActiveRecord::Relation<Mdm::WebForm>]
  def web_forms
    # query = <<-EOQ
    #       SELECT DISTINCT web_forms.*
    #       FROM hosts, services, web_sites, web_forms
    #       WHERE hosts.workspace_id = #{id} AND
    #         services.host_id = hosts.id AND
    #         web_sites.service_id = services.id AND
    #         web_forms.web_site_id = web_sites.id
    # EOQ
    # Mdm::WebForm.find_by_sql(query)
    Mdm::WebForm.joins(
      Mdm::WebForm.join_association(:web_site),
      Mdm::WebSite.join_association(:service),
      Mdm::Service.join_association(:host),
      Mdm::Host.join_association(:workspace)
    ).where(Mdm::Workspace[:id].eq(id)).uniq
  end


  # Web pages  found on {#web_sites}.
  #
  # @return [ActiveRecord::Relation<Mdm::WebPage>]
  def web_pages
    # query = <<-EOQ
    #       SELECT DISTINCT web_pages.*
    #         FROM hosts, services, web_sites, web_pages
    #         WHERE hosts.workspace_id = #{id} AND
    #         services.host_id = hosts.id AND
    #         web_sites.service_id = services.id AND
    #         web_pages.web_site_id = web_sites.id
    # EOQ
    # Mdm::WebPage.find_by_sql(query)
    Mdm::WebPage.joins(
      Mdm::WebPage.join_association(:web_site),
      Mdm::WebSite.join_association(:service),
      Mdm::Service.join_association(:host),
      Mdm::Host.join_association(:workspace)
    ).where(Mdm::Workspace[:id].eq(id)).uniq
  end

  # Web sites running on {#services}.
  #
  # @return [ActiveRecord::Relation<Mdm::WebSite>]
  def web_sites
    # query = <<-EOQ
    #       SELECT DISTINCT web_sites.*
    #         FROM hosts, services, web_sites
    #         WHERE hosts.workspace_id = #{id} AND
    #         services.host_id = hosts.id AND
    #         web_sites.service_id = services.id
    # EOQ
    # Mdm::WebSite.find_by_sql(query)
    Mdm::WebSite.joins(
      Mdm::WebSite.join_association(:service),
      Mdm::Service.join_association(:host),
      Mdm::Host.join_association(:workspace)
    ).where(Mdm::Workspace[:id].eq(id)).uniq
    
  end

  # Web vulnerability found on {#web_sites}.
  #
  # @return [ActiveRecord::Relation<Mdm::WebVuln>]
  def web_vulns
    # query = <<-EOQ
    #       SELECT DISTINCT web_vulns.*
    #       FROM hosts, services, web_sites, web_vulns
    #         WHERE hosts.workspace_id = #{id} AND
    #         services.host_id = hosts.id AND
    #         web_sites.service_id = services.id AND
    #         web_vulns.web_site_id = web_sites.id
    # EOQ
    # Mdm::WebVuln.find_by_sql(query)
    Mdm::WebVuln.joins(
      Mdm::WebVuln.join_association(:web_site),
      Mdm::WebSite.join_association(:service),
      Mdm::Service.join_association(:host),
      Mdm::Host.join_association(:workspace)
    ).where(Mdm::Workspace[:id].eq(id)).uniq
  end

  # Web forms on {#web_sites}.
  #
  # @return [ActiveRecord::Relation<Mdm::WebForm>]
  def unique_web_forms
    # query = <<-EOQ
    #       SELECT DISTINCT web_forms.web_site_id, web_forms.path, web_forms.method, web_forms.query
    #         FROM hosts, services, web_sites, web_forms
    #         WHERE hosts.workspace_id = #{id} AND
    #         services.host_id = hosts.id AND
    #         web_sites.service_id = services.id AND
    #         web_forms.web_site_id = web_sites.id
    # EOQ
    # Mdm::WebForm.find_by_sql(query)
    web_forms.select('web_forms.id, web_forms.web_site_id, web_forms.path, web_forms.method, web_forms.query')
  end

  # {#unique_web_forms} hosted on `addrs`.
  #
  # @param addrs [Array<IPAddr, String>] {Mdm::Host#address} for the {Mdm::Service#host} for the {Mdm::WebSite#service}
  #   for the {Mdm::WebForm#web_site}.
  # @return [Array<Mdm::WebForm>]
  def web_unique_forms(addrs=nil)
    forms = unique_web_forms
    if addrs
      forms.reject!{|f| not addrs.include?( f.web_site.service.host.address.to_s ) }
    end
    forms
  end

  private

  # Strips {#boundary}.
  #
  # @return [void]
  def normalize
    boundary.strip! if boundary
  end

  # Returns whether `string` is a valid IP address or IP address range.
  #
  # @return [true] if valid IP address or IP address range.
  # @return [false] otherwise.
  def valid_ip_or_range?(string)
    begin
      Rex::Socket::RangeWalker.new(string)
    rescue
      return false
    end
  end

  public

  Metasploit::Concern.run(self)
end

