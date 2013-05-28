# Creates the module_paths table used by {Mdm::Module::Path}.
class CreateModulePaths < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being {#up created}/{#down destroyed}.
  TABLE_NAME = :module_paths

  #
  # Methods
  #

  # Drops module_paths.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create module_paths.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :gem, :null => true
      t.string :name, :null => true
      t.text :real_path, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:gem, :name], :unique => true
      t.index :real_path, :unique => true
    end
  end
end
