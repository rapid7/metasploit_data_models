class Mdm::Route < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :subnet, :netmask
  
  #
  # Relations
  #

  # @!attribute [rw] session
  #   The session over which this route traverses.
  #
  #   @return [Mdm::Session]
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :routes

  Metasploit::Concern.run(self)
end
