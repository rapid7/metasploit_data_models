class Event < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :workspace
	belongs_to :host
	serialize :info, MsfModels::Base64Serializer.new
end

