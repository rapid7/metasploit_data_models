# Adds nexpose_consoles.names
class AddNameToNexposeConsolesTable < ActiveRecord::Migration
  # Removes nexpose_consoles.name.
  #
  # @return [void]
	def down
		remove_column :nexpose_consoles, :name
  end

  # Adds nexpose_consoles.name.
  #
  # @return [void]
  def up
		add_column :nexpose_consoles, :name, :text
	end
end

