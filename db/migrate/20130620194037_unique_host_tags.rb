# Ensure host_tags has host_id and tag_id set and they are unique
class UniqueHostTags < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being changed
  TABLE_NAME = :host_tags

  # Remove `:null => false` constraint on host_id and tag_id and indices.
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      #
      # Remove Foreign Key Indices
      #

      t.remove_index :host_id
      t.remove_index :tag_id

      #
      # Remove Unique Indices
      #

      t.remove_index [:host_id, :tag_id]
    end

    #
    # Change columns back to `:null => true`
    #

    change_column_null(TABLE_NAME, :host_id, true)
    change_column_null(TABLE_NAME, :tag_id, true)
  end

  # Adds `:null => false` constraint on host_id and tag_id and indices.
  #
  # @return [void]
  def up
    # Delete any records that won't pass `:null => false`
    execute "DELETE FROM #{TABLE_NAME} WHERE host_id IS NULL OR tag_id IS NULL"

    #
    # Change columns back to `:null => false`
    #

    change_column_null(TABLE_NAME, :host_id, false)
    change_column_null(TABLE_NAME, :tag_id, false)

    # Delete duplicate rows that won't pass index [:host, :tag_id], unique => true by taking the row with the highest
    # id
    #
    # @see http://stackoverflow.com/a/4442825
    execute "DELETE FROM host_tags " \
            "USING host_tags AS keep_host_tags " \
            "WHERE host_tags.host_id = keep_host_tags.host_id AND " \
                  "host_tags.tag_id = keep_host_tags.tag_id AND " \
                  "host_tags.id < keep_host_tags.id"

    change_table TABLE_NAME do |t|
      #
      # Foreign Key Indices
      #

      t.index :host_id
      t.index :tag_id

      #
      # Unique Indices
      #

      t.index [:host_id, :tag_id], :unique => true
    end
  end
end
