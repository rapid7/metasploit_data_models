class CreateTaskCreds < ActiveRecord::Migration[4.2]
  def change
    create_table :task_creds do |t|
      t.references :task, :null => false
      t.references :cred, :null => false
      t.timestamps null: false
    end
  end
end
