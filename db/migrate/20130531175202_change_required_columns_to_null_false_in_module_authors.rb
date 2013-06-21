# Change require {COLUMNS}, detail_id and name, to `:null => false` in module_authors.
class ChangeRequiredColumnsToNullFalseInModuleAuthors < MetasploitDataModels::ChangeRequiredColumnsToNullFalse
  #
  # CONSTANTS
  #

  # Name of columns that {#up} will change from `:null => true` to `:null => false`.
  COLUMNS = [
      :detail_id,
      :name
  ]
  # Table whose {COLUMNS} to change.
  TABLE_NAME = :module_authors
end
