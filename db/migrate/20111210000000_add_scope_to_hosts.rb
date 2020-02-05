class AddScopeToHosts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hosts, :scope, :text
  end

  def self.down
    remove_column :hosts, :scope
  end
end
