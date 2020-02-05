class AddUserPreferences < ActiveRecord::Migration[4.2]
	def self.up
		add_column :users, :prefs, :string, :limit => 524288
	end

	def self.down
		remove_column :users, :prefs
	end

end

