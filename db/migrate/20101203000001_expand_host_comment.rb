# Changes hosts.comment to text to remove its limit.
class ExpandHostComment < ActiveRecord::Migration
  # Changes hosts.comments back to string and restored 4k limit.
  #
  # @return [void]
  def down
    change_column :hosts, :comments, :string, :limit => 4096
  end

  # Changes hosts.comment to text to remove its limit.
  #
  # @return [void]
  def up
    change_column :hosts, :comments, :text
  end
end


