module MetasploitDataModels::ActiveRecordModels::ImportedCred
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Mdm::Workspace"
    }
  end
end

