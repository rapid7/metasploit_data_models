# Adds email_addresses.full to email_addresses so searching by the full email address, as is a common use case, is
# possible instead of only searching by local and domain portion of the email address.
class AddFullToEmailAddress < ActiveRecord::Migration
  # Adds full column to email_addresses table and gives it a unique index.
  #
  # @return [void]
  def change
    add_column :email_addresses, :full, :string, null: false
    add_index :email_addresses, :full, unique: true
  end
end
