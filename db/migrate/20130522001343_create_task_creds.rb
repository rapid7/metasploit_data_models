# Creats task_creds
class CreateTaskCreds < ActiveRecord::Migration
  # Creates tasks_creds.
  #
  # @return [void]
  def change
    create_table :task_creds do |t|
      t.references :task, :null => false
      t.references :cred, :null => false
      t.timestamps
    end
  end
end
