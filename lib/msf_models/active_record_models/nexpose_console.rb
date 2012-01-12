module MsfModels::ActiveRecordModels::NexposeConsole
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      serialize :cached_sites, ::MsfModels::Base64Serializer.new
    }
  end
end

