class Client < ActiveRecord::Base
	include Msf::DBManager::DBSave
	belongs_to :host
	belongs_to :campaign
end
