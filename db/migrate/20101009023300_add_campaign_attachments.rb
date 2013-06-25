# Adds campaign_id foreign key to attachments pointing to campaigns.
class AddCampaignAttachments < ActiveRecord::Migration
  #
  #
  # @return [void]
  def down
    remove_column :attachments, :campaign_id
  end

  # Adds campaign_id foreign key to attachments pointing to campaigns.
  #
  # @return [void]
  def up
    add_column :attachments, :campaign_id, :integer
  end
end


