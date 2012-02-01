module MetasploitDataModels::ActiveRecordModels::Profile
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave
      serialize :settings, ::MetasploitDataModels::Base64Serializer.new
    }
  end
end

