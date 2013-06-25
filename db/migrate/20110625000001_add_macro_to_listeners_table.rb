# Adds listeners.macro.
class AddMacroToListenersTable < ActiveRecord::Migration
  # Removes listeners.macro.
  #
  # @return [void]
	def down
		remove_column :listeners, :macro
  end

  # Adds listeners.macro.
  #
  # @return [void]
  def up
		add_column :listeners, :macro, :text
	end
end

