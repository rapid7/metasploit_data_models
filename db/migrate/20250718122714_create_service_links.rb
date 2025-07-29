class CreateServiceLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :service_links do |t|
      t.references :parent, null: false, foreign_key: { to_table: :services }
      t.references :child, null: false, foreign_key: { to_table: :services }
      t.timestamps
    end
    add_index :service_links, [:parent_id, :child_id], unique: true
  end
end

