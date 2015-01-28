class Mdm::Profile < ActiveRecord::Base
  #
  # Serializations
  #
  serialize :settings, MetasploitDataModels::Base64Serializer.new

  Metasploit::Concern.run(self)
end

