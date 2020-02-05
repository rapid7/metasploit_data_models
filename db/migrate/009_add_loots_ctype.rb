class AddLootsCtype < ActiveRecord::Migration[4.2]
	def self.up
		add_column :loots, :content_type, :string
	end

	def self.down
		remove_column :loots, :content_type
	end
end

