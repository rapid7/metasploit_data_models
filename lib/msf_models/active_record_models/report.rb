module MsfModels::ActiveRecordModels::Report
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
      serialize :options, ::MsfModels::Base64Serializer.new
    }
  end
end

