class ExpandHostComment < ActiveRecord::Migration[4.2]
	
	def self.up
		change_column :hosts, :comments, :text
	end
	
	def self.down
		change_column :hosts, :comments, :string, :limit => 4096
	end
end


