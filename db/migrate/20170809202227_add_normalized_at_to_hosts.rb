class AddNormalizedAtToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :normalized_at, :datetime, default: Time.at(0)
  end
end
