class ConvertServiceInfoToText < ActiveRecord::Migration[4.2]

	def self.up
		change_column :services, :info, :text
	end

	def self.down
		change_column :services, :info, :string, :limit => 65536
	end

end

