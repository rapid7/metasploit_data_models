# Creates authors
class CreateAuthors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :authors

  #
  # Methods
  #

  # Drops authors
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates authors
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :name, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index :name, :unique => true
    end
  end
end
