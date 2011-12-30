module Msf
class DBManager

class SessionEvent < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :session
end

end
end
