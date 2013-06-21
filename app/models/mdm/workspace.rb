class Mdm::Workspace < ActiveRecord::Base

  #
  # CONSTANTS
  #

  DEFAULT = 'default'

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] events
  #   Events that occured in this workspace.
  #
  #   @return [Array<Mdm::Event>]
  has_many :events, :class_name => 'Mdm::Event'

  # @!attribute [rw] hosts
  #   Hosts in this workspace.
  #
  #   @return [Array<Mdm::Host>]
  has_many :hosts, :class_name => 'Mdm::Host', :dependent => :destroy

  # @!attribute [rw] listeners
  #   Listeners running for this workspace.
  #
  #   @return [Array<Mdm::Listener>]
  has_many :listeners, :class_name => 'Mdm::Listener', :dependent => :destroy

  # @!attribute [rw] notes
  #   Notes about this workspace.
  #
  #   @return [Array<Mdm::Note>]
  has_many :notes, :class_name => 'Mdm::Note', :dependent => :destroy

  # @!attribute [rw] owner
  #   User that owns this workspace and has full permissions within this workspace even if they are not an
  #   {Mdm::User#admin administrator}.
  #
  #   @return [Mdm::User]
  belongs_to :owner, :class_name => 'Mdm::User', :foreign_key => 'owner_id'

  # @!attribute [rw] report_templates
  #   Templates for {#reports}.
  #
  #   @return [Array<Mdm::ReportTemplate>]
  has_many :report_templates, :class_name => 'Mdm::ReportTemplate', :dependent => :destroy

  # @!attribute [rw] reports
  #   Reports generated about data in this workspace.
  #
  #   @return [Array<Mdm::Report>]
  has_many :reports, :class_name => 'Mdm::Report', :dependent => :destroy

  # @!attribute [rw] tasks
  #   Tasks run inside this workspace.
  #
  #   @return [Array<Mdm::Task>]
  has_many :tasks, :class_name => 'Mdm::Task', :dependent => :destroy, :order => 'created_at DESC'

  # @!attribute [rw] users
  #   Users that are allowed to use this workspace.  Does not necessarily include all users, as an {Mdm::User#admin
  #   administrator} can access any workspace, even ones where they are not a member.
  has_and_belongs_to_many :users,
                          :class_name => 'Mdm::User',
                          :join_table => 'workspace_members',
                          :uniq => true

  #
  # :through => :hosts
  #

  # @!attribute [r] clients
  #   Campaign clients from {#hosts} in this workspace
  #
  #   @return [Array<Mdm::Client>]
  has_many :clients, :class_name => 'Mdm::Client', :through => :hosts

  # @!attribute [r] exploited_hosts
  #   Hosts exploited in this workspace.
  #
  #   @return [Array<Mdm::ExploitedHost>]
  has_many :exploited_hosts, :class_name => 'Mdm::ExploitedHost', :through => :hosts

  # @!attribute [r] host_tags
  #   Joins {#hosts} to {#tags}.
  #
  #   @return [Array<Mdm::HostTag>]
  has_many :host_tags, :class_name => 'Mdm::HostTag', :through => :hosts

  # @!attribute [r] loots
  #   Loot gathered from {#hosts} in this workspace.
  #
  #   @return [Array<Mdm::Loot>]
  has_many :loots, :class_name => 'Mdm::Loot', :through => :hosts

  # @!attribute [r] services
  #   Services running on {#hosts} in this workspace.
  #
  #   @return [Array<Mdm::Service>]
  has_many :services, :class_name => 'Mdm::Service', :foreign_key => 'service_id', :through => :hosts

  # @!attribute [r] sessions
  #   Sessions opened on {#hosts} in this workspace.
  #
  #    @return [Array<Mdm::Session>]
  has_many :sessions, :class_name => 'Mdm::Session', :through => :hosts

  # @!attribute [r] vulns
  #   Vulnerabilities found on {#hosts} in this workspace.
  #
  #   @return [Array<Mdm::Vuln>]
  has_many :vulns, :class_name => 'Mdm::Vuln', :through => :hosts

  #
  # :through => :host_tags
  #

  # @!attribute [r] tags
  #   Tags {#host_tags applied} to {#hosts} in this workspace.
  #
  #   @return [Array<Mdm::Tag>]
  has_many :tags, :class_name => 'Mdm::Tag', :through => :host_tags, :uniq => true

  #
  # :through => :services
  #

  # @!attribute [r] creds
  #   Credentials captured from {#services} in this workspace.
  #
  #   @return [Array<Mdm::Cred>]
  has_many :creds, :class_name => 'Mdm::Cred', :through => :services

  # @!attribute [r] web_sites
  #   Web sites running on {#services} in this workspace.
  #
  #   @return [Array<Mdm::WebSite>]
  has_many :web_sites, :class_name => 'Mdm::WebSite', :through => :services

  #
  # :through => :web_sites
  #

  # @!attribute [r] web_forms
  #   Forms on web sites on {#services} in this workspace.
  #
  #   @return [Array<Mdm::WebForm>]
  has_many :web_forms, :class_name => 'Mdm::WebForm', :through => :web_sites

  # @!attribute [r] web_pages
  #   Pages of web sites on {#services} in this workspace.
  #
  #   @return [Array<Mdm::WebPage>]
  has_many :web_pages, :class_name => 'Mdm::WebPage', :through => :web_sites

  # @!attribute [r] web_vulns
  #   Vulnerabilities found in {#web_sites} on {#services} in this workspace.
  #
  #   @return [Array<Mdm::WebVuln>]
  has_many :web_vulns, :class_name => 'Mdm::WebVuln', :through => :web_sites

  #
  # Callbacks
  #

  before_save :normalize

  #
  # Validations
  #

  validate :boundary_must_be_ip_range

  validates :description,
            :length => {
                :maximum => 4096
            }
  validates :name,
            :length => {
                :maximum => 255
            },
            :presence => true,
            :uniqueness => true

  # If limit_to_network is disabled, this will always return true.
  # Otherwise, return true only if all of the given IPs are within the project
  # boundaries.
  #
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
      allowed = true if ok_range.include_range? given_range
    end
    return allowed
  end

  def boundary_must_be_ip_range
    errors.add(:boundary, "must be a valid IP range") unless valid_ip_or_range?(boundary)
  end

  def self.default
    where(:name => DEFAULT).first_or_create!
  end

  def default?
    name == DEFAULT
  end

  def unique_web_forms
    query = <<-EOQ
          SELECT DISTINCT web_forms.web_site_id, web_forms.path, web_forms.method, web_forms.query  
            FROM hosts, services, web_sites, web_forms  
            WHERE hosts.workspace_id = #{id} AND        
            services.host_id = hosts.id AND         
            web_sites.service_id = services.id AND  
            web_forms.web_site_id = web_sites.id
    EOQ
    Mdm::WebForm.find_by_sql(query)
  end

  def web_unique_forms(addrs=nil)
    forms = unique_web_forms
    if addrs
      forms.reject!{|f| not addrs.include?( f.web_site.service.host.address ) }
    end
    forms
  end

  private

  def normalize
    boundary.strip! if boundary
  end

  def valid_ip_or_range?(string)
    begin
      Rex::Socket::RangeWalker.new(string)
    rescue
      return false
    end
  end

  ActiveSupport.run_load_hooks(:mdm_workspace, self)
end

