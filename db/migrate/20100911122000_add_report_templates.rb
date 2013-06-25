# Creates report_templates.
class AddReportTemplates < ActiveRecord::Migration
  # Drops report_templates.
  #
  # @return [void]
  def down
    drop_table :reports
  end

  # Creates report_templates.
  #
  # @return [void]
  def up
    create_table :report_templates do |t|
      t.integer   :workspace_id, :null => false, :default => 1
      t.string    :created_by
      t.string    :path, :limit  => 1024
      t.text      :name
      t.timestamps
    end
  end
end

