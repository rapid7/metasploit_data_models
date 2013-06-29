# Enforces unique task_hosts by adding unique index on (task_id, host_id).
class UniqueTaskHosts < MetasploitDataModels::UniqueTaskJoins
  #
  # CONSTANTS
  #

  # Column being used in unique index in addition to task_id.
  COLUMN_NAME = :host_id
  # Table having unique index added
  TABLE_NAME = :task_hosts
end
