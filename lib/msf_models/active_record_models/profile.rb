class Profile < ActiveRecord::Base
	include Msf::DBManager::DBSave
	serialize :settings, MsfModels::Base64Serializer.new
end

