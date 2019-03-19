class AddMacroToListenersTable < ActiveRecord::Migration[4.2]

	def self.up
		add_column :listeners, :macro, :text
	end

	def self.down
		remove_column :listeners, :macro
	end

end

