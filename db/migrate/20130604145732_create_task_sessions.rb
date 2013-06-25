# Creates task_sessions.
class CreateTaskSessions < ActiveRecord::Migration
  # Creates task_sessions.
  #
  # @return [void]
  def change
    create_table :task_sessions do |t|
      t.references :task, :null => false
      t.references :session, :null => false
      t.timestamps
    end
  end
end
