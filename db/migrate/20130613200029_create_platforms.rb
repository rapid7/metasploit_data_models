# Create platforms
class CreatePlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :platforms

  #
  # Methods
  #

  # Drops platforms.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates platforms.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.text :name, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index :name, :unique => true
    end
  end
end
