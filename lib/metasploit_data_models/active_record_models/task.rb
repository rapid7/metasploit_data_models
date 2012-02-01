module MetasploitDataModels::ActiveRecordModels::Task
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Mdm::Workspace"

      serialize :options, ::MetasploitDataModels::Base64Serializer.new
      serialize :result, ::MetasploitDataModels::Base64Serializer.new
      serialize :settings, ::MetasploitDataModels::Base64Serializer.new
    }
  end
end

