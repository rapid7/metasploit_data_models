class Mdm::Profile < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :active, :name, :owner, :settings
  
  #
  # Serializations
  #
  serialize :settings, MetasploitDataModels::Base64Serializer.new

  Metasploit::Concern.run(self)
end

