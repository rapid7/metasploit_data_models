# Changes module_targets to reference module_instances instead of module_details
class ReferenceModuleInstancesInModuleTargets < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being changed
  TABLE_NAME = :module_targets

  # Restores reference to module_details in module_targets.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.integer :index
      t.text :name

      #
      # Foreign Keys
      #
      t.references :detail
    end

    change_table TABLE_NAME do |t|
      # Restore old indices
      t.index :detail_id, :name => :index_module_targets_on_module_detail_id
    end
  end

  # Changes reference from module_details to module_instances in module_targets
  #
  # @return [void]
  def up
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.integer :index, :null => false
      t.text :name, :null => false

      #
      # Foreign Keys
      #

      t.references :module_instance, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :name], :unique => true
      t.index [:module_instance_id, :index], :unique => true
    end
  end
end
