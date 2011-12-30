module Msf
class DBManager

class WebPage < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :web_site
	serialize :headers, Msf::Base64Serializer.new
end

end
end

