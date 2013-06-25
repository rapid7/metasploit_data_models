# Changes creds.ptype limit from 16 to 256.
class ExpandCredPtypeColumn < ActiveRecord::Migration
  # Restores creds.ptype limit to 16.
  #
  # @return [void]
  def down
    change_column :creds, :ptype, :string, :limit => 16
  end

  # Increase creds.ptype limit to 256.
  #
  # @return [void]
  def up
    change_column :creds, :ptype, :string, :limit => 256
  end
end

