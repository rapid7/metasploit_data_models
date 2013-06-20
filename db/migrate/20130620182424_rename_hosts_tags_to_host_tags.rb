# Renames hosts_tags to host_tags to match rails pluralization rules for models.
class RenameHostsTagsToHostTags < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Old table name
  OLD_NAME = :hosts_tags
  # New table name
  NEW_NAME = :host_tags

  # Rename host_tags to hosts_tags
  #
  # @return [void]
  def down
    rename_table NEW_NAME, OLD_NAME
  end

  # Rename hosts_tags to host_tags
  #
  # @return [void]
  def up
    rename_table OLD_NAME, NEW_NAME
  end
end
