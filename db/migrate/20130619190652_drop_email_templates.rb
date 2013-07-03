# Drops email_templates table that used to back obsolete Mdm::EmailTemplate module for old-style campaigns.
class DropEmailTemplates < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :email_templates

  # Recreates email_templates, but does not restore data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :body
      t.string :name,
               :limit => 512
      t.text :prefs
      t.string :subject,
               :limit => 1024

      #
      # Foreign Keys
      #

      t.references :parent
      t.references :campaign
    end
  end

  # Drops email_templates
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
