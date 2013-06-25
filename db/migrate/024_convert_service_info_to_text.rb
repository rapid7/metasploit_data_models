# Converts services.info to text to remove its limit.
class ConvertServiceInfoToText < ActiveRecord::Migration
  # Restores 64k limit to services.info and makes it a string again.
  #
  # @return [void]
  def down
    change_column :services, :info, :string, :limit => 65536
  end

  # Converts services.info to text to remove its limit.
  #
  # @return [void]
  def up
    change_column :services, :info, :text
  end
end

