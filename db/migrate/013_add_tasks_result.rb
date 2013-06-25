# Adds result to tasks.
class AddTasksResult < ActiveRecord::Migration
  # Removes result from tasks.
  #
  # @return [void]
  def down
    remove_column :tasks, :result
  end

  # Adds result to tasks.
  #
  # @return [void]
  def up
    add_column :tasks, :result, :text
  end
end

