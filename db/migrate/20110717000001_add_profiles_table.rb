# Creates profiles.
class AddProfilesTable < ActiveRecord::Migration
  # Drops profiles.
  #
  # @return [void]
  def down
    drop_table :profiles
  end

  # Creates profiles.
  #
  # @return [void]
  def up
    create_table :profiles do |t|
      t.timestamps
      t.boolean :active, :default => true
      t.text :name
      t.text :owner
      t.binary :settings
    end
  end
end

