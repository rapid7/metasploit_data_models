# Adds sessions.last_seen.
class AddLastSeenToSessions < ActiveRecord::Migration
  # Removes sessions.last_seen.
  #
  # @return [void]
  def down
    remove_column :sessions, :last_seen
  end

  # Adds sessions.last_seen.
  #
  # @return [void]
  def up
    add_column :sessions, :last_seen, :timestamp
  end
end
