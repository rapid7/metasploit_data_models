class Macro < ActiveRecord::Base
	include Msf::DBManager::DBSave
	serialize :actions, MsfModels::Base64Serializer.new
	serialize :prefs, MsfModels::Base64Serializer.new
end

