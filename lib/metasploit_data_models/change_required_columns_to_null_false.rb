module MetasploitDataModels
  # Changes all the COLUMNS in the table with TABLE_NAME that are required from the table's mode, but were previously
  # `:null => true`, to `:null => false`.
  #
  #  @abstract Subclass and define COLUMNS as Array<Symbol> and TABLE_NAME as Symbol.
  class ChangeRequiredColumnsToNullFalse < ActiveRecord::Migration
    # Marks all the COLUMNS as `:null => true`
    #
    # @return [void]
    def down
      change_columns_null(true)
    end

    # Marks all the COLUMNS as `:null => false`
    #
    # @return [void]
    def up
      delete_null_rows

      change_columns_null(false)
    end

    private

    # Changes {COLUMNS} to either `:null => false` or `:null => true`.
    #
    # @param null [Boolean] `true` to allow column to be null. `false` to not allow column to be null.
    # @return [void]
    def change_columns_null(null)
      # Use self.class:: so constants are resolved in subclasses instead of this class.
      self.class::COLUMNS.each do |column|
        change_column_null(self.class::TABLE_NAME, column, false)
      end
    end

    # Delete row in TABLE_NAME that have `NULL` values for any of the COLUMNS, which would prevent
    # `change_column_null(table, column, false)`.
    #
    # @return [void]
    def delete_null_rows
      union_conditions = []

      # Use self.class:: so constants are resolved in subclasses instead of this class.
      self.class::COLUMNS.each do |column|
        column_condition = "#{column} IS NULL"
        union_conditions << column_condition
      end

      unioned_conditions = union_conditions.inject { |union, condition|
        "#{union} OR #{condition}"
      }

      # Use self.class:: so constants are resolved in subclasses instead of this class.
      statement = "DELETE FROM #{self.class::TABLE_NAME} WHERE #{unioned_conditions}"
      execute statement
    end
  end
end