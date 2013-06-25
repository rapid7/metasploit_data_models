# Changes events.info to text so it has no limit.
class EnlargeEventInfo < ActiveRecord::Migration
  # Restores 64k limit to info and change it back to a string from text.
  #
  # @return [void]
	def down
		change_column :events, :info, :string, :limit => 65535
  end

  # Changes events.info to text so it has no limit.
  #
  # @return [void]
  def up
    change_column :events, :info, :text
  end
end

