# Adds purpose to hosts.
class AddHostPurpose < ActiveRecord::Migration
  # Removes purpose from hosts.
  #
  # @return [void]
  def down
    remove_column :hosts, :purpose
  end

  # Adds purpose to hosts.
  #
  # @return [void]
  def up
    add_column :hosts, :purpose, :text
  end
end

