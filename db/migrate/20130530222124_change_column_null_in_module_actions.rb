# Changes module_actions.detail_id and module_actions.name to be `:null => false` to mirror presence validations
# on {Mdm::Module::Action#detail} and {Mdm::Module::Action#name}.
class ChangeColumnNullInModuleActions < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of columns that {#up} will change from `:null => true` to `:null => false`.
  COLUMNS = [
      :detail_id,
      :name
  ]
  # Table whose {COLUMNS} to change.
  KLASS = Mdm::Module::Action

  #
  # Methods
  #

  # Changes {COLUMNS} back to `:null => true`.
  #
  # @return [void]
  def down
    change_columns_null(true)
  end

  # Changes {COLUMNS} to `:null => false`.  Any rows with `NULL` columns will be deleted.
  #
  # @return [void]
  def up
    destroy_null_rows

    change_columns_null(false)
  end

  private

  # Changes {COLUMNS} to either `:null => false` or `:null => true`.
  #
  # @param null [Boolean] `true` to allow column to be null. `false` to not allow column to be null.
  # @return [void]
  def change_columns_null(null)
    COLUMNS.each do |column|
      change_column_null(KLASS.table_name, column, false)
    end
  end

  # Destroys row in {KLASS's KLASS} table that have `NULL` values for any of the {COLUMNS}, which would prevent
  # `change_column_null(table, column, false)`
  #
  # @return [void]
  def destroy_null_rows
    union_conditions = []

    module_actions = KLASS.arel_table

    COLUMNS.each do |column|
      column_condition = module_actions[column].not_eq(nil)
      union_conditions << column_condition
    end

    unioned_conditions = union_conditions.inject { |union, condition|
      union.or(condition)
    }

    KLASS.where(unioned_conditions).destroy_all
  end
end
