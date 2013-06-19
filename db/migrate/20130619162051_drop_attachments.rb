# Drops obsolete attachments table.
class DropAttachments < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table name
  TABLE_NAME = :attachments


  # Recreates attachments, but without data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.binary :data
      t.string :content_type,
               :limit => 512
      t.boolean :inline,
                :default => true,
                :null => false
      t.string :name,
               :limit => 512
      t.boolean :zip,
                :default => false,
                :null => false

      #
      # Foreign Keys
      #

      t.references :campaign
    end
  end

  # Drops attachments
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
