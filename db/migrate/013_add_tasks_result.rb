class AddTasksResult < ActiveRecord::Migration[4.2]
	def self.up
		add_column :tasks, :result, :text
	end

	def self.down
		remove_column :tasks, :result
	end
end

