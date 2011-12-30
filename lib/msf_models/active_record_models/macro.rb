module Msf
class DBManager

class Macro < ActiveRecord::Base
	include Msf::DBManager::DBSave
	serialize :actions, Msf::Base64Serializer.new
	serialize :prefs, Msf::Base64Serializer.new
end

end
end

