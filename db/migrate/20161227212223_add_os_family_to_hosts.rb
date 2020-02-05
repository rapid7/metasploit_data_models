class AddOsFamilyToHosts < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :os_family, :string
  end
end
