# Renames project_members to workspace_members.
class RenameWorkspaceMembers < ActiveRecord::Migration
  # Renames workspace_members to project_members.
  #
  # @return [void]
  def down
    rename_table :workspace_members, :project_members
  end

  # Renames project_members to workspace_members.
  #
  # @return [void]
  def up
    rename_table :project_members, :workspace_members
  end
end
