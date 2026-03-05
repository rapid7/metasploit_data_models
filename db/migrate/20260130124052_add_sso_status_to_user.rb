class AddSsoStatusToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sso_enabled, :boolean, null: false, default: false
  end
end
