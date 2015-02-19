class CreateModuleRuns < ActiveRecord::Migration
  def change
    create_table :module_runs do |t|
      t.string :trackable_type
      t.integer :trackable_id
      t.datetime :attempted_at
      t.integer :session_id
      t.integer :port
      t.string :proto
      t.text :fail_detail
      t.string :status
      t.string :username
      t.integer :user_id
      t.string :fail_reason
      t.text :module_name
      t.integer :module_detail_id

      t.timestamps
    end
  end
end
