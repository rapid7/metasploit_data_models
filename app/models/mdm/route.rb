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

  Metasploit::Concern.run(self)
end
