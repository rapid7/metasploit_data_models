class AddLootsFields < ActiveRecord::Migration[4.2]
	def self.up
		add_column :loots, :name, :text
		add_column :loots, :info, :text
	end

	def self.down
		remove_column :loots, :name
		remove_column :loots, :info
	end
end

