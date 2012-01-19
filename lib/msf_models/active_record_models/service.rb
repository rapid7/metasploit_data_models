module MsfModels::ActiveRecordModels::Service
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      has_many :vulns, :dependent => :destroy, :class_name => "Msm::Vuln"
      has_many :notes, :dependent => :destroy, :class_name => "Msm::Note"
      has_many :creds, :dependent => :destroy, :class_name => "Msm::Cred"
      has_many :exploited_hosts, :dependent => :destroy, :class_name => "Msm::ExploitedHost"
      has_many :web_sites, :dependent => :destroy, :class_name => "Msm::WebSite"
      belongs_to :host, :class_name => "Msm::Host"

      has_many :web_pages, :through => :web_sites
      has_many :web_forms, :through => :web_sites
      has_many :web_vulns, :through => :web_sites

      serialize :info, ::MsfModels::Base64Serializer.new

      def after_save
        if info_changed?
          host.normalize_os
        end
      end
    }
  end
end

