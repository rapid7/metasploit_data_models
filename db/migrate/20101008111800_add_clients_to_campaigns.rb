# Adds campaign_id foreign key on clients pointing to campaigns.
class AddClientsToCampaigns < ActiveRecord::Migration
  # Removes campaigns_id foreign key on clients.
  #
  # @return [void]
  def down
    remove_column :clients, :campaign_id
  end

  # Adds campaign_id foreign key on clients pointing to campaigns.
  #
  # @return [void]
  def up
    add_column :clients, :campaign_id, :integer
  end
end
