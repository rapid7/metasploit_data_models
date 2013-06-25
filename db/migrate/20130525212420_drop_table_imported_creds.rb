# Drops imported_creds.
class DropTableImportedCreds < ActiveRecord::Migration
  # Recreates imported_creds.
  #
  # @return [void]
  def down
    create_table :imported_creds do |t|
      t.integer   :workspace_id, :null => false, :default => 1
      t.string    :user, :limit  => 512
      t.string    :pass, :limit  => 512
      t.string    :ptype, :limit  => 16, :default => "password"
    end
  end

  # Drops imported_creds.
  #
  # @return [void]
  def up
    drop_table :imported_creds
  end
end
