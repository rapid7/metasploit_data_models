class CreateTaskSessions < ActiveRecord::Migration[4.2]
  def change
    create_table :task_sessions do |t|
      t.references :task, :null => false
      t.references :session, :null => false
      t.timestamps null: false
    end
  end
end
