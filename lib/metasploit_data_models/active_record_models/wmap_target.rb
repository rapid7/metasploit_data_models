module MetasploitDataModels::ActiveRecordModels::WmapTarget
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
    }
  end
end
