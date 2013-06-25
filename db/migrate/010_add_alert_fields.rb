# Adds critical and seen to both events and notes.
class AddAlertFields < ActiveRecord::Migration
  # Removes critical and seen to both events and notes.
  #
  # @return [void]
  def down
    remove_column :notes, :critical
    remove_column :notes, :seen
    remove_column :events, :critical
    remove_column :events, :seen
  end

  # Adds critical and seen to both events and notes.
  #
  # @return [void]
  def up
    add_column :notes, :critical, :boolean
    add_column :notes, :seen, :boolean
    add_column :events, :critical, :boolean
    add_column :events, :seen, :boolean
  end
end

