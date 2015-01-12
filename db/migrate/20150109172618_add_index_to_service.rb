class AddIndexToService < ActiveRecord::Migration
  def change
    add_index :services, [:host_id, :port, :proto], unique: true
  end
end
