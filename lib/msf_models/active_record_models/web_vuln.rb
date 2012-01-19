module MsfModels::ActiveRecordModels::WebVuln
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :web_site, :class_name => "Msm::WebSite"
      serialize :params, ::MsfModels::Base64Serializer.new
    }
  end
end

