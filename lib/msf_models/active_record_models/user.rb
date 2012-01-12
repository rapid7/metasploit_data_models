module MsfModels::ActiveRecordModels::User
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      serialize :prefs, ::MsfModels::Base64Serializer.new
    }
  end
end

