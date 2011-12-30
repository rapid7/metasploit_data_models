module Msf
class DBManager

class CredFile < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace
end

end
end

