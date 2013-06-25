# Creates creds.
class AddCredsTable < ActiveRecord::Migration
  # Drops creds.
  #
  # @return [void]
  def down
    drop_table :creds
  end

  # Creates creds.
  #
  # @return [void]
  def up
    create_table :creds do |t|
      t.integer   :service_id, :null => false
      t.timestamps
      t.string    :user, :limit => 2048
      t.string    :pass, :limit => 4096
      t.boolean   :active, :default => true
      t.string    :proof, :limit => 4096
      t.string    :ptype, :limit => 16
      t.integer   :source_id
      t.string    :source_type
    end
  end
end

