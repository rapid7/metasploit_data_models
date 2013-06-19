# Drop campaigns table for old-style campaigns
class DropCampaigns < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped
  TABLE_NAME = :campaigns

  # Recreates campaigns, but does not restore data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.datetime :created_at,
                 :null => false
      t.string :name,
               :limit => 512
      t.text :prefs
      t.datetime :started_at
      t.integer :status,
                :default => 0
      t.datetime :updated_at,
                 :null => false

      #
      # Foreign Keys
      #

      t.references :workspace,
                   :null => false
    end
  end

  # Drop campaigns
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
