# Adds workspaces.limit_to_network
class AddLimitToNetworkToWorkspaces < ActiveRecord::Migration
  # Remove workspaces.limit_to_network.
  #
  # @return [void]
  def down
    remove_column :workspaces, :limit_to_network
  end

  # Adds workspaces.limit_to_network
  #
  # @return [void]
  def up
    add_column :workspaces, :limit_to_network, :boolean, :null => false, :default => false
  end
end
