class AddTaskIdToReportsTable < ActiveRecord::Migration[4.2]

	def self.up
		add_column :reports, :task_id, :integer
	end

	def self.down
		remove_column :reports, :task_id
	end

end
