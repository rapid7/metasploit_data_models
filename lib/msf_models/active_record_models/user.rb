module Msf
class DBManager

class User < ActiveRecord::Base
	include Msf::DBManager::DBSave

	serialize :prefs, Msf::Base64Serializer.new
end

end
end

