class Mdm::Client < ActiveRecord::Base
  #
  # Associations
  #
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :clients
  
  Metasploit::Concern.run(self)
end
