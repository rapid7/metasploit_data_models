# Drops web_teamplates that was used with obsolete Mdm::WebTemplates model for old-style campaigns.
class DropWebTemplates < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :web_templates

  # Recreates web_templates, but does not restore data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.string :body,
               :limit => 524288
      t.string :name,
               :limit => 512
      t.text :prefs
      t.string :title,
               :limit => 512

      #
      # Foreign Keys
      #

      t.references :campaign
    end
  end

  # Drops web_templates
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
