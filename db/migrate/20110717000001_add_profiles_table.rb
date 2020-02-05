class AddProfilesTable < ActiveRecord::Migration[4.2]
	def self.up
		create_table :profiles do |t|
			t.timestamps null: false
			t.boolean :active, :default => true
			t.text :name
			t.text :owner
			t.binary :settings
		end
	end
	def self.down
		drop_table :profiles
	end
end

