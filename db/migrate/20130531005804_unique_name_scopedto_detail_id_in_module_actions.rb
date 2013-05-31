# Changes the index on module_actions from detail_id to a unique index on (detail_id, name) to enforce that only
# one action of a given name should exist for a given module.
class UniqueNameScopedtoDetailIdInModuleActions < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table whose indicies to change.
  TABLE_NAME = :module_actions

  #
  # Methods
  #

  # Removes unique index on (detail_id, name) and restores the index on detail_id.
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      t.remove_index [:detail_id, :name]

      t.index :detail_id, :name => 'index_module_actions_on_module_detail_id'
    end
  end

  # Replaces index on detail_id with unique index on detail_id and name.
  #
  # @return [void]
  def up
    change_table TABLE_NAME do |t|
      t.remove_index :name => 'index_module_actions_on_module_detail_id'

      t.index [:detail_id, :name], :unique => true
    end
  end
end
