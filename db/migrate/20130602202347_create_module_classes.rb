# Creates module_classes table
class CreateModuleClasses < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being created
  TABLE_NAME = :module_classes

  #
  # Methods
  #

  # Drops module_classes
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates module_classes
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :full_name, :null => false
      t.string :module_type, :null => false
      t.string :payload_type, :null => true
      t.text :reference_name, :null => false

      #
      # References
      #

      t.references :rank, :null => false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key Indices
      #

      t.index :rank_id

      #
      # Unique Indices
      #

      t.index :full_name, :unique => true
      t.index [:module_type, :reference_name], :unique => true
    end
  end
end
