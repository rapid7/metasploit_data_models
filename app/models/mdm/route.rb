class Mdm::Route < ActiveRecord::Base
  
  #
  # Associations
  #

  # @!attribute [rw] session
  #   The session over which this route traverses.
  #
  #   @return [Mdm::Session]
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :routes

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :subnet, :netmask
  
  # Foreign Keys
  
  attr_accessible :session_id
  
  # Model Associations
  
  attr_accessible :session
  
  Metasploit::Concern.run(self)
end
