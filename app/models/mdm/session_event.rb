class Mdm::SessionEvent < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :etype, :command, :output, :remote_path, :local_path
  
  #
  # Relations
  #

  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :events

  Metasploit::Concern.run(self)
end
