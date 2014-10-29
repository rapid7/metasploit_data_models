class Mdm::Client < ActiveRecord::Base
  #
  # Associations
  #
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :clients

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :ua_string, :ua_name, :ua_ver
  
  # Foreign Keys
  
  attr_accessible :host_id
  
  # Model Associations
  
  attr_accessible :host
  
  Metasploit::Concern.run(self)
end
