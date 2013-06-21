# Change require {COLUMNS}, token, to `:null => false` in api_keys.
class ChangeRequiredColumnsToNullFalseInApiKeys < MetasploitDataModels::ChangeRequiredColumnsToNullFalse
  #
  # CONSTANTS
  #

  # Name of columns that {#up} will change from `:null => true` to `:null => false`.
  COLUMNS = [
      :token
  ]
  # Table whose {COLUMNS} to change.
  TABLE_NAME = :api_keys
end
