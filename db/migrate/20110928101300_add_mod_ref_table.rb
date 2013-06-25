# Creates mod_refs.
class AddModRefTable < ActiveRecord::Migration
  # Drops mod_refs.
  #
  # @return [void]
  def down
    drop_table :mod_refs
  end

  # Creates mod_refs.
  #
  # @return [void]
  def up
    create_table :mod_refs do |t|
      t.string :module, :limit => 1024
      t.string :mtype, :limit => 128
      t.text :ref
    end
  end
end
