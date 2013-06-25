# Removes campaign_id foreign key from clients.
class RemoveCampaignIdFromClients < ActiveRecord::Migration
  # Restores campaign_id foreign key on clients pointing to obsolete campaigns.
  #
  # @return [void]
  def down
    change_table :clients do |t|
      t.references :campaign
    end
  end

  # Removes campaign_id foreign key from clients.
  #
  # @return [void]
  def up
    remove_column :clients, :campaign_id
  end
end
