# Creates module_ranks
class CreateModuleRanks < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  TABLE_NAME = :module_ranks

  #
  # Methods
  #

  # Drops module_ranks
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create module_ranks
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :name, :null => false
      t.integer :number, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index :name, :unique => true
      t.index :number, :unique => true
    end
  end
end
