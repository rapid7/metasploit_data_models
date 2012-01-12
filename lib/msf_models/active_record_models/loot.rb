module MsfModels::ActiveRecordModels::Loot
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      belongs_to :workspace
      belongs_to :host
      belongs_to :service

      serialize :data, ::MsfModels::Base64Serializer.new
    }
  end
end

