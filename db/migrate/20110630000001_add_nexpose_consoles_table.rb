# Creates nexpose_consoles.
class AddNexposeConsolesTable < ActiveRecord::Migration
  # Drops nexpose_consoles.
  #
  # @return [void]
  def down
    drop_table :nexpose_consoles
  end

  # Creates nexpose_consoles.
  #
  # @return [void]
  def up
    create_table :nexpose_consoles do |t|
      t.timestamps
      t.boolean :enabled, :default => true
      t.text :owner
      t.text :address
      t.integer :port, :default => 3780
      t.text :username
      t.text :password
      t.text :status
      t.text :version
      t.text :cert
      t.binary :cached_sites
    end
  end
end

