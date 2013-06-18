# Drops module_refs because it has been replaced by module_references
class DropModuleRefs < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :module_refs

  # Recreates module_refs
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :name

      #
      # Foreign Keys
      #

      t.references :detail
    end

    change_table TABLE_NAME do |t|
      t.index :detail_id
      t.index :name
    end
  end

  # Drop module_refs
  def up
    drop_table TABLE_NAME
  end
end
