# Creates reports.
class AddReports < ActiveRecord::Migration
  # Drops reports.
  #
  # @return [void]
  def down
    drop_table :reports
  end

  # Creates reports.
  #
  # @return [void]
  def up
    create_table :reports do |t|
      t.integer   :workspace_id, :null => false, :default => 1
      t.string    :created_by
      t.string    :rtype
      t.string    :path, :limit  => 1024
      t.text      :options
      t.timestamps
    end
  end
end

