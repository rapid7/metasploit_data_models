class AddResourceToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :resource, :jsonb, null: false, default: {}
  end
end
