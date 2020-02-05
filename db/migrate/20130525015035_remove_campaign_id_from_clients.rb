class RemoveCampaignIdFromClients < ActiveRecord::Migration[4.2]
  def up
    remove_column :clients, :campaign_id
  end

  def down
    remove_column :clients, :campaign_id, :integer
  end
end
