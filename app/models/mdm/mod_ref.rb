class Mdm::ModRef < ActiveRecord::Base
  
  Metasploit::Concern.run(self)
end
