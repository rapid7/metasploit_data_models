# Creates workspaces and adds workspace_id foreign key on hosts.  Also removes unique index on hosts.address.
class AddWorkspaces < ActiveRecord::Migration
  # Drops workspaces and removes workspace_id foreign key on hosts.  Restores unique index on hosts.address.
  #
  # @return [void]
  def down
    drop_table :workspaces

    change_table :hosts do |t|
      t.remove   :workspace_id
    end

    add_index :hosts, :address, :unique => true
  end

  # Creates workspaces and adds workspace_id foreign key on hosts.  Also removes unique index on hosts.address.
  #
  # @return [void]
  def up
    create_table :workspaces do |t|
      t.string    :name
      t.timestamps
    end

    change_table :hosts do |t|
      t.integer   :workspace_id, :required => true
    end

    remove_index :hosts, :column => :address
  end
end
