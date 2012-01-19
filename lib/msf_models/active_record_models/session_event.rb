module MsfModels::ActiveRecordModels::SessionEvent
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :session, :class_name => "Msm::Session"
    }
  end
end
