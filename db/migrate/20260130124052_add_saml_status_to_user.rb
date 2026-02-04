class AddSamlStatusToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :saml_enabled, :boolean, null: false, default: false
  end
end
