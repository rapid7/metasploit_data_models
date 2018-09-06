class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.string :name
      t.string :uuid
      t.boolean :registered
      t.integer :timestamp
      t.string :arch
      t.string :platform
      t.string :urls
      t.string :description
      t.references :workspace


      t.timestamps null: false
    end
  end
end
