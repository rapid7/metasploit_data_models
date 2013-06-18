# Drop obsolete refs that has been replaced by references.  Data in rows already translated by
# {TranslateRefsToReferences}.
class DropRefs < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :refs

  # Recreate refs, but without data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      t.string :name, :limit => 512
      t.timestamps
    end

    change_table TABLE_NAME do |t|
      t.index :name
    end
  end

  # Drops refs
  #
  # @return [void]
  def up
     drop_table TABLE_NAME
  end
end
