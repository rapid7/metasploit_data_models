# Drops mod_refs.
class DropModRefs < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table being dropped.
  TABLE_NAME = :mod_refs

  # Restores mod_refs.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      t.string :module, :limit => 1024
      t.string :mtype,  :limit => 128
      t.text :ref
    end
  end

  # Drops mod_refs.
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
