# Creates module_relationships
class CreateModuleRelationships < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :module_relationships

  #
  # Methods
  #

  def down
    drop_table TABLE_NAME
  end

  def up
    create_table TABLE_NAME do |t|
      #
      # References
      #

      t.references :ancestor, :null => false
      t.references :descendant, :null => false
    end

    change_table TABLE_NAME do |t|
      # A {Mdm::Module::Class descendant} should only list a given {Mdm::Module::Ancestor ancestor} once.
      t.index [:descendant_id, :ancestor_id], :unique => true
    end
  end
end
