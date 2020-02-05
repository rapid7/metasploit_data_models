class RemovePayloadWorkspaces < ActiveRecord::Migration[4.2]
  def change
    remove_column :payloads, :workspace_id, :references
  end
end
