# Removes Mdm::Module::Detail#file and adds Mdm::Module::Detail#parent_path_id.
class AddParentPathToModuleDetails < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being changed.
  TABLE_NAME = :module_details

  #
  # Methods
  #

  # Restores module_details.file and removes parent_path_id foreign_key pointing to paths.  Tables rows are deleted.
  #
  # @return [void]
  def down
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.text :file

      t.remove_references :parent_path
    end
  end

  # Adds parent_path_id foreign key pointing to paths and removes module_details.file.  Tables rows are deleted.
  #
  # @return [void]
  def up
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.references :parent_path, :null => false

      t.remove :file
    end
  end
end
