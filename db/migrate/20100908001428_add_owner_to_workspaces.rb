# Adds owner_id foreign key to workspaces pointing to users.
class AddOwnerToWorkspaces < ActiveRecord::Migration
  # Removes owner_id foreign key from workspaces.
  #
  # @return [void]
  def down
    remove_column :workspaces, :owner_id
  end

  # Adds owner_id foreign key to workspaces pointing to users.
  #
  # @return [void]
  def up
    add_column :workspaces, :owner_id, :integer
  end
end
