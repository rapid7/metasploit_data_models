class Mdm::Macro < ActiveRecord::Base
  extend MetasploitDataModels::SerializedPrefs
  #
  # Mass Assignment Security
  #

  attr_accessible :owner, :name, :description, :actions, :prefs
  

  #
  # Serialization
  #

  serialize :actions, MetasploitDataModels::Base64Serializer.new
  serialize :prefs, MetasploitDataModels::Base64Serializer.new
  serialized_prefs_attr_accessor :max_time

  #
  # Validations
  #

  validates :name, :presence => true, :format => /\A[^'|"]+\z/

  Metasploit::Concern.run(self)
end

