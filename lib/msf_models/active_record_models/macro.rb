module MsfModels::ActiveRecordModels::Macro
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      serialize :actions, ::MsfModels::Base64Serializer.new
      serialize :prefs, ::MsfModels::Base64Serializer.new
    }
  end
end

