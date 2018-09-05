class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.string :puid
      t.string :name
      t.boolean :registered
      t.integer :timestamp
      t.string :arch
      t.string :platform
      t.integer :xor1
      t.integer :xor2

      t.timestamps null: false
    end
  end
end
