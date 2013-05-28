# Removes Mdm::Module::Detail#file and adds Mdm::Module::Detail#parent_path_id.
class AddParentPathToModuleDetails < ActiveRecord::Migration
  TABLE_NAME = :module_details

  def down
    say(
        'Clearing cache because Mdm::Module::Detail#file cannot be derived from Mdm::Module::Path#real_path, ' \
        'Mdm::Module::Detail#mtype and Mdm::Module::Detail#refname because mtype and refname are not :null => false',
        true
    )
    Mdm::Module::Detail.destroy_all

    change_table TABLE_NAME do |t|
      t.text :file

      t.remove_references :parent_path
    end
  end

  def up
    say(
        'Clearing cache because Mdm::Module::Path#gem and Mdm::Module::Path#name cannot be derived from ' \
        'Mdm::Module::Detail#file',
        true
    )
    Mdm::Module::Detail.destroy_all

    change_table TABLE_NAME do |t|
      t.references :parent_path, :null => false

      t.remove :file
    end
  end
end
