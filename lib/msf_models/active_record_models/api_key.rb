module MsfModels


class ApiKey < ActiveRecord::Base
	include Msf::DBManager::DBSave
end

end

