# Adds task_id foreign key reports that points to reports.
class AddTaskIdToReportsTable < ActiveRecord::Migration
  # Removes task_id foreign key from reports.
  #
  # @return [void]
	def down
		remove_column :reports, :task_id
	end

  # Adds task_id foreign key reports that points to reports.
  #
  # @return [void]
	def up
		add_column :reports, :task_id, :integer
	end
end
