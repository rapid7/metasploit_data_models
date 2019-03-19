class CreateTaskHosts < ActiveRecord::Migration[4.2]
  def change
    create_table :task_hosts do |t|
      t.references :task, :null => false
      t.references :host, :null => false
      t.timestamps null: false
    end
  end
end
