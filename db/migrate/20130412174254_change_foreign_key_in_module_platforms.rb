# Changes `module_platforms.module_detail_id` to `module_platforms.detail_id` so that foreign key matches the conventional
# name when `Mdm::ModuleDetail` became `Mdm::Module::Detail`.
class ChangeForeignKeyInModulePlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # New name for column.
  NEW_COLUMN_NAME = :detail_id
  # Old name for column.
  OLD_COLUMN_NAME = :module_detail_id
  # Name of table where {OLD_COLUMN_NAME} is being renamed to {NEW_COLUMN_NAME}.
  TABLE_NAME = :module_platforms

  # Renames `module_platforms.detail_id` to `module_platforms.module_detail_id`.
  #
  # @return [void]
  def down
    rename_column TABLE_NAME, NEW_COLUMN_NAME, OLD_COLUMN_NAME
  end

  # Rename `module_platforms.module_detail_id` to `module_platforms.detail_id`
  #
  # @return [void]
  def up
    rename_column TABLE_NAME, OLD_COLUMN_NAME, NEW_COLUMN_NAME
  end
end
