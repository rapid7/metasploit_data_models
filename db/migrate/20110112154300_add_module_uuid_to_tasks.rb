# Adds tasks.module_uuid.
class AddModuleUuidToTasks < ActiveRecord::Migration
  # Removes tasks.module_uuid.
  #
  # @return [void]
  def down
    remove_column :tasks, :module_uuid
  end

  # Adds tasks.module_uuid.
  #
  # @return [void]
  def up
    add_column :tasks, :module_uuid, :string, :limit => 8
  end
end
