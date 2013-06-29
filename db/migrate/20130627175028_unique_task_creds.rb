# Enforces unique task_creds by adding unique index on (task_id, cred_id).
class UniqueTaskCreds < MetasploitDataModels::UniqueTaskJoins
  #
  # CONSTANTS
  #

  # Column being used in unique index in addition to task_id.
  COLUMN_NAME = :cred_id
  # Table having unique index added
  TABLE_NAME = :task_creds
end
