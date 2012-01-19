module MsfModels::ActiveRecordModels::ImportedCred
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace, :class_name => "Msm::Workspace"
    }
  end
end

