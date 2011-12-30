module Msf
class DBManager

class Loot < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace
	belongs_to :host
	belongs_to :service

	serialize :data, Msf::Base64Serializer.new
end

end
end

