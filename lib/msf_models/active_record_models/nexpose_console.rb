class NexposeConsole < ActiveRecord::Base
	include Msf::DBManager::DBSave
	serialize :cached_sites, MsfModels::Base64Serializer.new
end

