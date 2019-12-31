class CreateAsyncCallbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :async_callbacks do |t|
      t.string :uuid, :null => false
      t.integer :timestamp, :null => false
      t.string :listener_uri
      t.string :target_host
      t.string :target_port

      t.timestamps null: false
      t.uuid null: false
    end
  end
end
