class AddVirtualHostToHosts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hosts, :virtual_host, :text
  end

  def self.down
    remove_column :hosts, :viritual_host
  end
end
