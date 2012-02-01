module MetasploitDataModels::ActiveRecordModels::WebTemplate
  def self.included(base)
    base.class_eval{
      belongs_to :campaign, :class_name => "Mdm::Campaign"
      extend ::MetasploitDataModels::SerializedPrefs
      serialize :prefs, ::MetasploitDataModels::Base64Serializer.new

      serialized_prefs_attr_accessor :exploit_type
      serialized_prefs_attr_accessor :exploit_name, :exploit_opts
    }
  end
end

