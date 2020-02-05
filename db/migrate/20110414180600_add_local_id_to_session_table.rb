class AddLocalIdToSessionTable < ActiveRecord::Migration[4.2]

	def self.up
		add_column :sessions, :local_id, :integer
	end

	def self.down
		remove_column :sessions, :local_id
	end

end
