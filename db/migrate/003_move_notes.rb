# Moves notes
class MoveNotes < ActiveRecord::Migration
  # Reassociates notes with hosts instead of services and workspaces.
  #
  # @return [void]
  def down
    remove_column :notes, :workspace_id
    remove_column :notes, :service_id
    change_table :notes do |t|
      t.integer :host_id, :null => false
    end
  end

  # Remove associations to notes from hosts and replaces it with association to services and workspaces.
  #
  # @return [void]
  def up
    # Remove the host requirement.  We'll add the column back in below.
    remove_column :notes, :host_id
    change_table :notes do |t|
      t.integer :workspace_id, :null => false, :default => 1
      t.integer :service_id
      t.integer :host_id
    end
  end
end

