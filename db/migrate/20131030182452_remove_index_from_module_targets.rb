# Removes the index column from module_targets.
class RemoveIndexFromModuleTargets < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  TABLE_NAME = :module_targets

  # Restores index column and the (module_instance_id, index) index.
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      t.integer :index, null: false

      t.index [:module_instance_id, :index], unique: true
    end
  end

  # Remove index column and the (module_instance_id, index) index
  #
  # @return [void]
  def up
    change_table TABLE_NAME do |t|
      t.remove_index [:module_instance_id, :index]

      t.remove :index
    end
  end
end
