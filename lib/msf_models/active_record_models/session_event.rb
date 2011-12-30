class SessionEvent < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :session
end
