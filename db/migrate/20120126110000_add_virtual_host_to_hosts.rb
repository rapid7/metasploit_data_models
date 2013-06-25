# Adds hosts.virtual_hosts to represent Virtual Machine host.
class AddVirtualHostToHosts < ActiveRecord::Migration
  # Removes hosts.virtual_hosts.
  #
  # @return [void]
  def down
    remove_column :hosts, :virtual_host
  end

  # Adds hosts.virtual_hosts to represent Virtual Machine host.
  #
  # @return [void]
  def up
    add_column :hosts, :virtual_host, :text
  end
end
