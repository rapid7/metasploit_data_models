# Drops module_mixins because it is unused.
class DropModuleMixins < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped
  TABLE_NAME = :module_mixins

  #
  # Methods
  #

  # Recreates module_mixins.
  def down
    create_table TABLE_NAME do |t|
      t.text :name

      t.references :detail
    end

    change_table TABLE_NAME do |t|
      t.index :detail_id
    end
  end

  # Drops module_mixins.
  def up
    drop_table TABLE_NAME
  end
end
