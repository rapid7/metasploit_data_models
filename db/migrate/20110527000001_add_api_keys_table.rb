class AddApiKeysTable < ActiveRecord::Migration[4.2]
	def self.up
		create_table :api_keys do |t|
			t.text :token
			t.timestamps null: false
		end
	end
	def self.down
		drop_table :api_keys
	end
end

