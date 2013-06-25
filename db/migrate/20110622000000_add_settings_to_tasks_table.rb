# Adds tasks.settings.
class AddSettingsToTasksTable < ActiveRecord::Migration
  # Removes tasks.settings.
  #
  # @return [void]
  def down
    remove_column :tasks, :settings
  end

  # Adds tasks.settings.
  #
  # @return [void]
  def up
    add_column :tasks, :settings, :binary
  end
end

