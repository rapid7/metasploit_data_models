# Changes notes.data to text so that it has no limit.
class ExpandNotes < ActiveRecord::Migration
  # Changes notes.data back to a string with 64k limit.
  #
  # @return [void]
  def down
    change_column :notes, :data, :string, :limit => 65536
  end

  # Changes notes.data to text so that it has no limit.
  #
  # @return [void]
  def up
    change_column :notes, :data, :text
  end
end

