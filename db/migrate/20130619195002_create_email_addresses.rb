# Create email_addresses for use with email addresses used in module author credits.
class CreateEmailAddresses < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created.
  TABLE_NAME = :email_addresses

  # Drops email_addresses.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create email_addresses
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :domain, :null => false
      t.string :local, :null => false
    end

    change_table TABLE_NAME do |t|
      #
      # Search indices
      #

      t.index :domain
      t.index :local

      #
      # Unique indices
      #

      t.index [:domain, :local], :unique => true
    end
  end
end
