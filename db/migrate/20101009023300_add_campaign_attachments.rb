

class AddCampaignAttachments < ActiveRecord::Migration[4.2]

	def self.up
		add_column :attachments, :campaign_id, :integer
	end

	def self.down
		remove_column :attachments, :campaign_id
	end

end


