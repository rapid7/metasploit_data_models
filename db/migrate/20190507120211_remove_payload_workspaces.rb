class RemovePayloadWorkspaces < ActiveRecord::Migration
  def change
    remove_column :payloads, :workspace_id, :references
  end
end
