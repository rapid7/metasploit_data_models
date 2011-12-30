class Ref < ActiveRecord::Base
	include Msf::DBManager::DBSave
	has_and_belongs_to_many :vulns, :join_table => :vulns_refs
end
