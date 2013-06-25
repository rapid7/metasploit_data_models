# Adds IPv6 scope as hosts.scope.
class AddScopeToHosts < ActiveRecord::Migration
  # Removes hosts.scope.
  #
  # @return [void]
  def down
    remove_column :hosts, :scope
  end

  # Adds IPv6 scope as hosts.scope.
  #
  # @return [void]
  def up
    add_column :hosts, :scope, :text
  end
end
