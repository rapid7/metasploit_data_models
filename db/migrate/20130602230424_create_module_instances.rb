# Creates module_instances
class CreateModuleInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being created
  TABLE_NAME = :module_instances

  # Drops module_instances
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates module_instances
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.text :description, :null => false
      t.date :disclosed_on, :null => true
      t.string :license, :null => false
      t.text :name, :null => false
      t.boolean :privileged, :null => false
      t.string :stance, :null => false

      #
      # References
      #

      t.references :default_action, :null => true
      t.references :default_target, :null => true
      t.references :module_class, :null => false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key/Unique Indices
      #

      # only one row can have a given default action or default target because module_actions and module_target have a
      # module_instance_id foreign key
      t.index :default_action_id, :unique => true
      t.index :default_target_id, :unique => true

      # only one row can have a given module_class_id by definition because the metadata for a Class<Msf::Module>
      # instance is stored in the instance and the class.
      t.index :module_class_id, :unique => true
    end
  end
end
