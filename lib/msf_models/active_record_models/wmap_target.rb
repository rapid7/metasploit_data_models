module Msf
class DBManager

# WMAP Target object definition
class WmapTarget < ::ActiveRecord::Base
	include Msf::DBManager::DBSave
	# Magic.
end

end
end