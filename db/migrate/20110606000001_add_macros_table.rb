# Creates macros.
class AddMacrosTable < ActiveRecord::Migration
  # Drops macros.
  #
  # @return [void]
  def down
    drop_table :macros
  end

  # Creates macros.
  #
  # @return [void]
  def up
    create_table :macros do |t|
      t.timestamps
      t.text :owner
      t.text :name
      t.text :description
      t.binary :actions
      t.binary :prefs
    end
  end
end

