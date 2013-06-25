# Adds users.prefs.
class AddUserPreferences < ActiveRecord::Migration
  # Removes users.prefs.
  #
  # @return [void]
  def down
    remove_column :users, :prefs
  end

  # Adds users.prefs.
  #
  # @return [void]
  def up
    add_column :users, :prefs, :string, :limit => 524288
  end
end

