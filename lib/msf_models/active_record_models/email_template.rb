module MsfModels::ActiveRecordModels::EmailTemplate
  def self.included(base)
    base.class_eval{
      belongs_to :campaign, :class_name => "Msm::Campaign"
      has_and_belongs_to_many :attachments, :class_name => "Msm::Attachment"

      extend MsfModels::SerializedPrefs

      serialize :prefs, MsfModels::Base64Serializer.new

      serialized_prefs_attr_accessor :exploit_module, :exploit_attach_name
      serialized_prefs_attr_accessor :attach_exe
      serialized_prefs_attr_accessor :attach_exploit
    }
  end
end

