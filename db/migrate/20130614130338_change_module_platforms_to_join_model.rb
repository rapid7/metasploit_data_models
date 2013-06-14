# Changes module_platforms from single reference to obsolete module_details table to a join table between
# module_instances and platforms.
class ChangeModulePlatformsToJoinModel < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being changed
  TABLE_NAME = :module_platforms

  # Restore old module_platforms schema of referencing module_details table and having name.
  #
  # @return [void]
  def down
    # no columns are preserved so just drop table
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      t.text :name

      t.references :detail
    end

    change_table TABLE_NAME do |t|
      t.index :detail_id
    end
  end

  #
  #
  # @return [void]
  def up
    # no columns are preserved so just drop table
    drop_table TABLE_NAME

    create_table TABLE_NAME do |t|
      t.references :module_instance, :null => false
      t.references :platform, :null => false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :platform_id], :unique => true
    end
  end
end
