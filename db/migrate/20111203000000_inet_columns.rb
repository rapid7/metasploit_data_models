# Changes hosts.address to an PostgreSQL INET column and drops the no longer needed hosts.address6.
#
# @todo https://www.pivotaltracker.com/story/show/52252353
class InetColumns < ActiveRecord::Migration
  # Changes hosts.address back to text and restores hosts.address6.
  #
  # @return [void]
  def down
    change_column :hosts, :address, :text
    add_column :hosts, :address6, :text
  end

  # Changes hosts.address to an PostgreSQL INET column and drops the no longer needed hosts.address6.
  #
  # @return [void]
  def up
    change_column :hosts, :address, 'INET using address::INET'
    remove_column :hosts, :address6
  end
end
