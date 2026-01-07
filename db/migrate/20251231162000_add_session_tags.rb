class AddSessionTags < ActiveRecord::Migration[7.0]

	def change
		create_table :sessions_tags do |t|
			t.integer :session_id
			t.integer :tag_id
		end
		add_index :sessions_tags, [:session_id, :tag_id], unique: true
	end

	def self.down
		drop_table :sessions_tags
	end
end
