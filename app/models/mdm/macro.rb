class Mdm::Macro < ActiveRecord::Base
  extend MetasploitDataModels::SerializedPrefs

  #
  # Serialization
  #

  serialize :actions, MetasploitDataModels::Base64Serializer.new
  serialize :prefs, MetasploitDataModels::Base64Serializer.new
  serialized_prefs_attr_accessor :max_time

  #
  # Validations
  #

  validates :name, :presence => true, :format => /^[^'|"]+$/

  Metasploit::Concern.run(self)
end

