# Adds downloaded_at to reports.
class AddReportDownloadedAt < ActiveRecord::Migration
  # Removes downloaded_at to reports.
  #
  # @return [void]
  def down
    remove_column :reports, :downloaded_at
  end

  # Adds downloaded_at to reports.
  #
  # @return [void]
  def up
    add_column :reports, :downloaded_at, :timestamp
  end
end

