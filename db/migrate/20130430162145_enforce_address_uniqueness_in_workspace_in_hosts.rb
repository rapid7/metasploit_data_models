# Changes index on address so it scoped to workspace_id and is unique to match the validation in {Mdm::Host} on
# {Mdm::Host#address}.
class EnforceAddressUniquenessInWorkspaceInHosts < ActiveRecord::Migration
  TABLE_NAME = :hosts

  # Restores old index on address
  def down
    change_table TABLE_NAME do |t|
      t.remove_index [:workspace_id, :address]

      t.index :address
    end
  end

  # Make index on address scope to workspace_id and be unique
  def up
    change_table TABLE_NAME do |t|
      t.remove_index :address

      t.index [:workspace_id, :address], :unique => true
    end
  end
end
