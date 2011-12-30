module Msf
class DBManager

class ModRef < ActiveRecord::Base
	include Msf::DBManager::DBSave
end

end
end
