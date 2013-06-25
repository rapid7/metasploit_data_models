# Creates task_hosts.
class CreateTaskHosts < ActiveRecord::Migration
  # Creates task_hosts.
  #
  # @return [void]
  def change
    create_table :task_hosts do |t|
      t.references :task, :null => false
      t.references :host, :null => false
      t.timestamps
    end
  end
end
