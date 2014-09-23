class Mdm::Client < ActiveRecord::Base
  #
  # Mass Assignment Security
  #
  
  attr_accessible :ua_string, :ua_name, :ua_ver
  
  #
  # Relations
  #
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :clients

  Metasploit::Concern.run(self)
end
