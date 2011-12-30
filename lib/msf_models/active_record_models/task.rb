class Task < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace

	serialize :options, Msf::Base64Serializer.new
	serialize :result, Msf::Base64Serializer.new
	serialize :settings, Msf::Base64Serializer.new
end

