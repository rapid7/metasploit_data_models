module Msf
class DBManager

class Event < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :workspace
	belongs_to :host
	serialize :info, Msf::Base64Serializer.new
end

end
end

