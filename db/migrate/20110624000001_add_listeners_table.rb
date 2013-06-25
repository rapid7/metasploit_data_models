# Creates listeners.
class AddListenersTable < ActiveRecord::Migration
  # Drops listeners.
  #
  # @return [void]
  def down
    drop_table :listeners
  end

  # Creates listeners.
  #
  # @return [void]
  def up
    create_table :listeners do |t|
      t.timestamps
      t.integer :workspace_id, :null => false, :default => 1
      t.integer :task_id
      t.boolean :enabled, :default => true
      t.text :owner
      t.text :payload
      t.text :address
      t.integer :port
      t.binary :options
    end
  end
end

