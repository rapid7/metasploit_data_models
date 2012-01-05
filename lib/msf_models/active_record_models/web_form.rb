class WebForm < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :web_site
	serialize :params, MsfModels::Base64Serializer.new
end

