module MsfModels::ActiveRecordModels::WmapRequest
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
    }
  end
end
