class Mdm::ModRef < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :module, :mtype, :ref
  
  Metasploit::Concern.run(self)
end
