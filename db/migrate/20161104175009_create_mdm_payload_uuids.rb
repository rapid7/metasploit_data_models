class CreateMdmPayloadUuids < ActiveRecord::Migration
  def change
    create_table :payload_uuids do |t|
      t.string :uid, null: false
      t.string :arch, null: false
      t.string :platform, null: false
      t.integer :timestamp, null: false
      t.string :payload, null: false
      t.json :datastore, null: false
      t.string :name, null: false
      t.text :urls, array:true, default: []

      t.timestamps null: false
      
      t.index :uid, unique: true
    end
  end
end
