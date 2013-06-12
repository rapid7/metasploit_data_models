# Changes module_actions so it references module_instances instead of module_details
class AssociateModuleActionsToModuleInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table whose references are changing
  TABLE_NAME = :module_actions

  # Removes module_actions.module_instance_id and adds module_actions.detail_id
  #
  # @return [void]
  def down
    # DELETE all rows because detail_id cannot be derived.
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.remove_references :module_instance

      t.references :detail, :null => false

      t.index [:detail_id, :name], :unique => true
    end
  end

  # Remove module_actions.detail_id and adds module_actions.module_instance_id
  #
  # @return [void]
  def up
    # DELETE all rows because module_instance_id cannot be derived.
    execute "DELETE FROM #{TABLE_NAME}"

    change_table TABLE_NAME do |t|
      t.remove_references :detail

      t.references :module_instance, :null => false

      t.index [:module_instance_id, :name], :unique => true
    end
  end
end
