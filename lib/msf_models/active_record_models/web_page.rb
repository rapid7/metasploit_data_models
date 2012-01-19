module MsfModels::ActiveRecordModels::WebPage
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :web_site, :class_name => "Msm::WebSite"
      serialize :headers, ::MsfModels::Base64Serializer.new
    }
  end
end

