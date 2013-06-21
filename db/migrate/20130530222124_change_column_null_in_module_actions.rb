# Changes module_actions.detail_id and module_actions.name to be `:null => false` to mirror presence validations
# on `Mdm::Module::Action#detail` and `Mdm::Module::Action#name`.
class ChangeColumnNullInModuleActions < MetasploitDataModels::ChangeRequiredColumnsToNullFalse
  #
  # CONSTANTS
  #

  # Name of columns that {#up} will change from `:null => true` to `:null => false`.
  COLUMNS = [
      :detail_id,
      :name
  ]
  # Table whose {COLUMNS} to change.
  TABLE_NAME = :module_actions
end
