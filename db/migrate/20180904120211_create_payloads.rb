class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.string :name
      t.string :uuid
      t.integer :timestamp
      t.string :arch
      t.string :platform
      t.string :urls
      t.string :description
      t.references :workspace
      t.string :raw_payload
      t.string :raw_payload_hash
      t.string :build_opts

      t.timestamps null: false
    end
  end
end
