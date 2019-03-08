class CreateAsyncCallbacks < ActiveRecord::Migration
  def change
    create_table :async_callbacks do |t|
      t.string :uuid
      t.integer :timestamp
      t.string :listener_uri
      t.string :target_host
      t.string :target_port

      t.timestamps null: false
      t.uuid null: false
    end
  end
end
