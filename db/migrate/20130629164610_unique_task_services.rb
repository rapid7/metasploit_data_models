# Enforces unique task_services by adding unique index on (task_id, host_id).
class UniqueTaskServices < MetasploitDataModels::UniqueTaskJoins
  #
  # CONSTANTS
  #

  # Column being used in unique index in addition to task_id.
  COLUMN_NAME = :service_id
  # Table having unique index added.
  TABLE_NAME = :task_services
end
