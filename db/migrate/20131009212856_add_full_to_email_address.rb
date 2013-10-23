class AddFullToEmailAddress < ActiveRecord::Migration
  def change
    add_column :email_addresses, :full, :string, null: false
    add_index :email_addresses, :full, unique: true
  end
end
