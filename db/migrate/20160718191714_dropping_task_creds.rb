class DroppingTaskCreds < ActiveRecord::Migration
  def up
    drop_table :task_creds
  end
  def down
    create_table :task_creds do |t|
      t.references :task, :null => false
      t.references :cred, :null => false
      t.timestamps null: false
    end
  end
end
