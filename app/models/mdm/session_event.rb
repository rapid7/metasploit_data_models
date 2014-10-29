class Mdm::SessionEvent < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :events

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :etype, :command, :output, :remote_path, :local_path
  
  # Foreign Keys
  
  attr_accessible :session_id
  
  # Model Associations
  
  attr_accessible :session
  
  Metasploit::Concern.run(self)
end
