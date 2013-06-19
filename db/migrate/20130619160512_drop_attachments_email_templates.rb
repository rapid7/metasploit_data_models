# Drops obsolete attachments_email_templates join table.
class DropAttachmentsEmailTemplates < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :attachments_email_templates

  #
  # Methods
  #

  # Recreates attachments_email_templates table
  #
  # @return [void]
  def down
    create_table TABLE_NAME, :id => false do |t|
      t.references :attachment
      t.references :email_template
    end
  end

  # Drops attachmetns_email_templates table
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
