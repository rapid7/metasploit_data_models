class Mdm::SessionEvent < ActiveRecord::Base
  #
  # Relations
  #

  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :events

  Metasploit::Concern.run(self)
end
