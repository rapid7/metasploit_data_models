class CreateTaskServices < ActiveRecord::Migration
  def change
    create_table :task_services do |t|
      t.references :task, :null => false
      t.references :service, :null => false
      t.timestamps
    end
  end
end
