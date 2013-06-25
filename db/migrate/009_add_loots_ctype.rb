# Adds content_type to loots.
class AddLootsCtype < ActiveRecord::Migration
  # Removes content_type from loots.
  #
  # @return [void]
  def down
    remove_column :loots, :content_type
  end

  # Adds content_type to loots.
  #
  # @return [void]
  def up
    add_column :loots, :content_type, :string
  end
end

