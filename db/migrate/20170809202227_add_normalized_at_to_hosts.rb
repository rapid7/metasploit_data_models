class AddNormalizedAtToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :normalized_at, :datetime
  end
end
