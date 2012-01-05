class WebPage < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :web_site
	serialize :headers, MsfModels::Base64Serializer.new
end

