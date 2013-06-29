module MetasploitDataModels
  # Enforces unique row in `TABLE_NAME` (defined in subclass) by adding a unique index on the task_id and `COLUMN_NAME`
  # (defined in subclass).  Deletes any duplicate rows that have the same task_id and `COLUMN_NAME` before adding the
  # unique index.
  #
  # @abstract Define TABLE_NAME for the name of the join table and COLUMN_NAME with the foreign key that is not task_id.
  class UniqueTaskJoins < ActiveRecord::Migration
    # Returns names of columns in `TABLE_NAME` (defined in subclass) that should be in the unique index.
    #
    # @return [Array(:task_id, Symbol)]
    def self.column_names
      [
          :task_id,
          # Use self so constant comes from subclass.
          self::COLUMN_NAME
      ]
    end

    # Remove unique index on {column_names} in `TABLE_NAME` (defined in subclass).
    #
    # @return
    def down
      change_table self.class::TABLE_NAME do |t|
        t.remove_index self.class.column_names
      end
    end

    # Add unique index on {column_names} in `TABLE_NAME` (defined in subclass) after removing duplicates.
    #
    # @return [void]
    def up
      # Delete duplicate rows that won't pass `index COLUMN_NAMES, :unique => true` by taking the row with the highest
      # id.
      #
      # @see http://stackoverflow.com/a/4442825

      # use `self.class::` so constant is resolved in subclass.
      table_name = self.class::TABLE_NAME
      column_name = self.class::COLUMN_NAME
      keep_alias = "keep_#{table_name}"

      execute "DELETE from #{table_name} " \
              "USING #{table_name} AS #{keep_alias} " \
              "WHERE #{table_name}.#{column_name} = #{keep_alias}.#{column_name} AND " \
                    "#{table_name}.task_id = #{keep_alias}.task_id AND " \
                    "#{table_name}.id < #{keep_alias}.id"

      change_table table_name do |t|
        t.index self.class.column_names, :unique => true
      end
    end
  end
end
