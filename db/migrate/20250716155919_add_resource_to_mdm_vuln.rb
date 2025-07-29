class AddResourceToMdmVuln < ActiveRecord::Migration[7.0]
  def change
    add_column :vulns, :resource, :jsonb, null: false, default: {}
  end
end
