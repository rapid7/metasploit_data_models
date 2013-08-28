# Removes tables associated with old-style campaigns.
class RemoveCampaigns < ActiveRecord::Migration
  # Drops attachments, attachments_email_templates, campaigns, email_addresses, email_templates, and web_templates.
  #
  # @return [void]
  def up
    drop_table :attachments
    drop_table :attachments_email_templates
    drop_table :campaigns
    drop_table :email_addresses
    drop_table :email_templates
    drop_table :web_templates
  end
end
