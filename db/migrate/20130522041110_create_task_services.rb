# Creates task_services.
class CreateTaskServices < ActiveRecord::Migration
  # Creates task_services.
  #
  # @return [void]
  def change
    create_table :task_services do |t|
      t.references :task, :null => false
      t.references :service, :null => false
      t.timestamps
    end
  end
end
