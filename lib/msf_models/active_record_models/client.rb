module MsfModels::ActiveRecordModels::Client
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      belongs_to :host
      belongs_to :campaign
    }
  end
end
