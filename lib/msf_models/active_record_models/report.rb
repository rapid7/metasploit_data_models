class Report < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace
	serialize :options, Msf::Base64Serializer.new
end

