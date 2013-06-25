# Adds sessions.local_id.
class AddLocalIdToSessionTable < ActiveRecord::Migration
  # Removes sessions.local_id.
  #
  # @return [void]
  def down
    remove_column :sessions, :local_id
  end

  # Adds sessions.local_id.
  #
  # @return [void]
  def up
    add_column :sessions, :local_id, :integer
  end
end
