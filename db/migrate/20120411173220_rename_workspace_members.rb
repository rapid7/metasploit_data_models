class RenameWorkspaceMembers < ActiveRecord::Migration[4.2]
  def up
    rename_table :project_members, :workspace_members
  end

  def down
    rename_table :workspace_members, :project_members
  end
end
