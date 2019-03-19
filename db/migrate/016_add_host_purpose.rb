class AddHostPurpose < ActiveRecord::Migration[4.2]
	def self.up
		add_column :hosts, :purpose, :text
	end

	def self.down
		remove_column :hosts, :purpose
	end
end

