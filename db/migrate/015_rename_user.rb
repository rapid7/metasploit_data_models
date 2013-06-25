# Renames user to username on events.
class RenameUser < ActiveRecord::Migration
  # Restores username to user in events.
  #
  # @return [void]
  def down
    remove_column :events, :username
    change_table :events do |t|
      t.string    :user
    end
  end

  # Renames user to username on events.
  #
  # @return [void]
  def up
    remove_column :events, :user
    change_table :events do |t|
      t.string    :username
    end
  end
end

