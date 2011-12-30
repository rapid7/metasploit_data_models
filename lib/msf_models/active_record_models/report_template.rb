module Msf
class DBManager

class ReportTemplate < ActiveRecord::Base
	include Msf::DBManager::DBSave

	belongs_to :workspace
end

end
end

