class NexposeConsole < ActiveRecord::Base
	include Msf::DBManager::DBSave
	serialize :cached_sites, Msf::Base64Serializer.new
end

