class AddIndicesToNotes < ActiveRecord::Migration[6.1]
  def change
    add_index :notes, :host_id
    add_index :notes, :service_id
  end
end
