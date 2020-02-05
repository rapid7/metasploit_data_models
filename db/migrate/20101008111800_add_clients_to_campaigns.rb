
class AddClientsToCampaigns < ActiveRecord::Migration[4.2]
	def self.up
		add_column :clients, :campaign_id, :integer
	end

	def self.down
		remove_column :clients, :campaign_id
	end
end
