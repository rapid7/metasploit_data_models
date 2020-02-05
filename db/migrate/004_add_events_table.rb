class AddEventsTable < ActiveRecord::Migration[4.2]
	def self.up
		create_table :events do |t|
			t.integer   :workspace_id
			t.integer   :host_id
			t.timestamp :created_at
			t.string    :user
			t.string    :name
			t.string    :info
		end
	end
	def self.down
		drop_table :events
	end
end

