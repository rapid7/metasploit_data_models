# Drops obsolete email_addresses.
class DropEmailAddresses < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being dropped.
  TABLE_NAME = :email_addresses

  #
  # Methods
  #

  # Recreates email_addresses, but does not restore data.
  #
  # @return [void]
  def down
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.string :address,
               :limit => 512
      t.datetime :clicked_at
      t.string :first_name,
               :limit => 512
      t.string :last_name,
               :limit => 512
      t.boolean :sent,
                :default => false,
                :null => false

      #
      # Foreign Keys
      #

      t.references :campaign,
                   :null => false
    end
  end

  # Drops email_addresses
  #
  # @return [void]
  def up
    drop_table TABLE_NAME
  end
end
