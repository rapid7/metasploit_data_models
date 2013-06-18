# Creates module_references
class CreateModuleReferences < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :module_references

  #
  # Methods
  #

  # Drops module_references
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates module_references
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :module_instance, :null => false
      t.references :reference, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :reference_id], :unique => true
    end
  end
end
