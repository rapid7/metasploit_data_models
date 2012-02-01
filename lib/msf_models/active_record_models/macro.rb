module MsfModels::ActiveRecordModels::Macro
  def self.included(base)
    base.class_eval{
      include Msf::DBManager::DBSave

      extend MsfModels::SerializedPrefs

      serialize :actions, ::MsfModels::Base64Serializer.new
      serialize :prefs, ::MsfModels::Base64Serializer.new
      serialized_prefs_attr_accessor :max_time

      validates :name, :presence => true, :format => /^[^'|"]+$/
    }
  end
end

