class AddLimitToNetworkToWorkspaces < ActiveRecord::Migration[4.2]
	def self.up
		add_column :workspaces, :limit_to_network, :boolean, :null => false, :default => false
	end

	def self.down
		remove_column :workspaces, :limit_to_network
	end
end
