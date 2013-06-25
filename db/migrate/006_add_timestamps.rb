# Adds 'created_at' and 'updated_at' columns to every primary table.
class AddTimestamps < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Tables that need a new created_at column.
  TABLES_NEEDING_CREATED_AT = [
      :wmap_targets
  ]
  # Tables that need created column renamed to created_at.
  TABLES_NEEDING_RENAME = [
      :clients,
      :hosts,
      :notes,
      :refs,
      :services,
      :vulns,
      :wmap_requests
  ]
  # Tables taht need a new updated_at column.
  TABLES_NEEDING_UPDATED_AT = [
      :clients,
      :events,
      :hosts,
      :notes,
      :refs,
      :services,
      :vulns,
      :wmap_requests,
      :wmap_targets
  ]

  # Reverts columns in {TABLES_NEEDING_RENAME} from created_at to created.  Removes created_at columns from
  # {TABLES_NEEDING_CREATED_AT}. Removes updated_at columns from {TABLES_NEEDING_UPDATED_AT}.
  #
  # @return [void]
  def down
    TABLES_NEEDING_RENAME.each { |t| rename_column t, :created_at, :created }

    TABLES_NEEDING_CREATED_AT.each { |t| remove_column t, :created_at }

    TABLES_NEEDING_UPDATED_AT.each { |t| remove_column t, :updated_at }
  end

  # Renames created to created_at in {TABLES_NEEDING_RENAME}. Adds created_at column to {TABLES_NEEDING_CREATED_AT}.
  # Adds updated_at column to {TABLES_NEEDING_UPDATED_AT}.
  #
  # @return [void]
  def up
    TABLES_NEEDING_RENAME.each { |t| rename_column t, :created, :created_at }

    TABLES_NEEDING_CREATED_AT.each { |t| add_column t, :created_at, :datetime }

    TABLES_NEEDING_UPDATED_AT.each { |t| add_column t, :updated_at, :datetime }
  end
end
