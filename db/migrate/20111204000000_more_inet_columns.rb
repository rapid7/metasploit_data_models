# Changes wmap_requests.address and wmap_targets.address to PostgreSQL INET columns.  Removes the no longer needed
# wmap_requests.address6 and wmap_targets.address6.
#
# @todo https://www.pivotaltracker.com/story/show/52252353
class MoreInetColumns < ActiveRecord::Migration
  # Changes wmap_requests.address and wmap_targets.address back to text.  Restores wmap_requests.address6 and
  # wmap_targets.address6 columns.
  #
  # @return [void]
  def down
    change_column :wmap_requests, :address, :string, :limit => 16
    add_column :wmap_requests, :address6, :string, :limit => 255
    change_column :wmap_targets, :address, :string, :limit => 16
    add_column :wmap_targets, :address6, :string, :limit => 255
  end

  # Changes wmap_requests.address and wmap_targets.address to PostgreSQL INET columns.  Removes the no longer needed
  # wmap_requests.address6 and wmap_targets.address6.
  #
  # @return [void]
  def up
    change_column :wmap_requests, :address, 'INET using address::INET'
    remove_column :wmap_requests, :address6
    change_column :wmap_targets, :address, 'INET using address::INET'
    remove_column :wmap_targets, :address6
  end
end
