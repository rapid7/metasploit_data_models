class WebVuln < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :web_site
	serialize :params, Msf::Base64Serializer.new
end

