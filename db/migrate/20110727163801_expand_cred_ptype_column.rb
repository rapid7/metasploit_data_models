class ExpandCredPtypeColumn < ActiveRecord::Migration[4.2]
	def self.up
		change_column :creds, :ptype, :string, :limit => 256
	end
	def self.down
		change_column :creds, :ptype, :string, :limit => 16
	end
end

