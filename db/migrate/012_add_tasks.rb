# Creates tasks.
class AddTasks < ActiveRecord::Migration
  # Drops tasks.
  #
  # @return [void]
  def down
    drop_table :tasks
  end

  # Creates tasks.
  #
  # @return [void]
  def up
    create_table :tasks do |t|
      t.integer   :workspace_id, :null => false, :default => 1
      t.string    :created_by
      t.string    :module
      t.datetime  :completed_at
      t.string    :path, :limit  => 1024
      t.string    :info
      t.string    :description
      t.integer   :progress
      t.text      :options
      t.text      :error
      t.timestamps
    end
  end
end

