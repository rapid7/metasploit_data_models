module MsfModels::ActiveRecordModels::Profile
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      serialize :settings, ::MsfModels::Base64Serializer.new
    }
  end
end

