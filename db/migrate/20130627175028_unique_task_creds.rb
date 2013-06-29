# Enforces unique task_creds by adding unique index on (task_id, cred_id).
class UniqueTaskCreds < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Columns being used in unique index, in order.
  COLUMN_NAMES = [
      :task_id,
      :cred_id
  ]
  # Table having unique index added
  TABLE_NAME = :task_creds

  # Remove unique index on token in api_keys
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      t.remove_index COLUMN_NAMES
    end
  end

  # Add unique index on (task_id, cred_id) in task_creds after removing duplicates
  #
  # @return [void]
  def up
    # Delete duplicate rows that won't pass `index [:task_id, :cred_i], unique => true` by taking the row with the
    # highest id
    #
    # @see http://stackoverflow.com/a/4442825
    execute "DELETE FROM task_creds " \
            "USING task_creds AS keep_task_creds " \
            "WHERE task_creds.cred_id = keep_task_creds.cred_id AND " \
                  "task_creds.task_id = keep_task_creds.task_id AND " \
                  "task_creds.id < keep_task_creds.id"

    change_table TABLE_NAME do |t|
      t.index COLUMN_NAMES, :unique => true
    end
  end
end
