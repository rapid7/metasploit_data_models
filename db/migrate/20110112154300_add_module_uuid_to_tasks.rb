class AddModuleUuidToTasks < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tasks, :module_uuid, :string, :limit => 8
  end

  def self.down
    remove_column :tasks, :module_uuid
  end
end
