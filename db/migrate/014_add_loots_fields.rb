# Adds info and name to loots.
class AddLootsFields < ActiveRecord::Migration
  # Removes info and name from loots.
  #
  # @return [void]
	def down
		remove_column :loots, :name
		remove_column :loots, :info
	end

  # Adds info and name to loots.
  #
  # @return [void]
	def up
		add_column :loots, :name, :text
		add_column :loots, :info, :text
	end
end

