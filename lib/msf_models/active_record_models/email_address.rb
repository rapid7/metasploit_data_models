class EmailAddress < ActiveRecord::Base
	has_one :campaign
end
