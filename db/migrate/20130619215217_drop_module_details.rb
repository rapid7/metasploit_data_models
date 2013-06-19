# Drops obsolete module_details.
class DropModuleDetails < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped
  TABLE_NAME = :module_details

  # Recreate module_details.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :default_action
      t.integer :default_target
      t.text :description
      t.datetime :disclosure_date
      t.text :fullname
      t.string :license
      t.datetime :mtime
      t.string :mtype
      t.text :name
      t.boolean :privileged
      t.text :refname
      t.integer :rank
      t.boolean :ready
      t.string :stance

      #
      # Foreign Keys
      #

      t.references :parent_path, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index :description
      t.index :mtype
      t.index :name
      t.index :refname
    end
  end

  # Drops module_details
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
