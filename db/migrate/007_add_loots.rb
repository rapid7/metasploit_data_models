class AddLoots < ActiveRecord::Migration[4.2]

	def self.up
		create_table :loots do |t|
			t.integer   :workspace_id, :null => false, :default => 1
			t.integer   :host_id
			t.integer   :service_id
			t.string    :ltype, :limit => 512
			t.string    :path, :limit  => 1024
			t.text      :data
			t.timestamps null: false
		end
	end

	def self.down
		drop_table :loots
	end

end

