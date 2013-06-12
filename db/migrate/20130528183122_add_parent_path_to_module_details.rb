# Removes Mdm::Module::Detail#file and adds Mdm::Module::Detail#parent_path_id.
class AddParentPathToModuleDetails < ActiveRecord::Migration
  TABLE_NAME = :module_details

  def down
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.text :file

      t.remove_references :parent_path
    end
  end

  def up
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.references :parent_path, :null => false

      t.remove :file
    end
  end
end
