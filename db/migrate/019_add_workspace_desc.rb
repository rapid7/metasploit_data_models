# Adds hosts.comments and workspaces.description
class AddWorkspaceDesc < ActiveRecord::Migration
  # Removes hosts.comments and workspaces.description.
  #
  # @return [void]
  def down
    change_table :workspaces do |t|
      t.remove :description
    end

    change_table :hosts do |t|
      t.remove :comments
    end
  end

  # Adds hosts.comments and workspaces.description.
  #
  # @return [void]
  def up
    change_table :workspaces do |t|
      t.string :description, :limit => 4096
    end

    change_table :hosts do |t|
      t.string :comments, :limit => 4096
    end
  end
end

