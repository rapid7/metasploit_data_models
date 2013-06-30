# Enforces unique task_sessions by adding unique index on (task_id, session_id).
class UniqueTaskSessions < MetasploitDataModels::UniqueTaskJoins
  #
  # CONSTANTS
  #

  # Column being used in unique index in addition to task_id.
  COLUMN_NAME = :session_id
  # Table having unique index added.
  TABLE_NAME = :task_sessions
end
