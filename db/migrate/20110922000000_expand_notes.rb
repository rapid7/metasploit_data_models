class ExpandNotes < ActiveRecord::Migration[4.2]
	def self.up
		change_column :notes, :data, :text
	end
	def self.down
		change_column :notes, :data, :string, :limit => 65536
	end
end

