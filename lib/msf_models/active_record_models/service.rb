module MsfModels::ActiveRecordModels::Service
  def self.included(base)
    base.class_eval{
	    eval("STATES = ['open', 'closed', 'filtered', 'unknown']") unless defined? STATES
      include Msf::DBManager::DBSave
      has_many :vulns, :dependent => :destroy, :class_name => "Msm::Vuln"
      has_many :notes, :dependent => :destroy, :class_name => "Msm::Note"
      has_many :creds, :dependent => :destroy, :class_name => "Msm::Cred"
      has_many :exploited_hosts, :dependent => :destroy, :class_name => "Msm::ExploitedHost"
      has_many :web_sites, :dependent => :destroy, :class_name => "Msm::WebSite"
      has_many :web_pages, :through => :web_sites, :class_name => "Msm::WebPage"
      has_many :web_forms, :through => :web_sites, :class_name => "Msm::WebForm"
      has_many :web_vulns, :through => :web_sites, :class_name => "Msm::WebVuln"
      
      belongs_to :host, :class_name => "Msm::Host"

      has_many :web_pages, :through => :web_sites
      has_many :web_forms, :through => :web_sites
      has_many :web_vulns, :through => :web_sites

      serialize :info, ::MsfModels::Base64Serializer.new
      scope :inactive, where("state <> ?", "open")
      scope :with_state, lambda { |a_state|  where("services.state = ?", a_state)}
      scope :search, lambda { |*args|
        where([
          "services.name ILIKE ? OR " +
          "services.info ILIKE ? OR " +
          "services.port = ? ",
          "%#{args[0]}%", "%#{args[0]}%", (args[0].to_i > 0) ? args[0].to_i : 99999
        ])
      }

      after_save :normalize_host_os

      def normalize_host_os
        if info_changed?
          host.normalize_os
        end
      end
    }
  end
end

