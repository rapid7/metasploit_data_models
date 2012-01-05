class Loot < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace
	belongs_to :host
	belongs_to :service

	serialize :data, MsfModels::Base64Serializer.new
end

