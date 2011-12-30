class User < ActiveRecord::Base
	include Msf::DBManager::DBSave

	serialize :prefs, Msf::Base64Serializer.new
end

