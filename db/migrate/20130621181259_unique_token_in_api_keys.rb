# Adds unique index of token in api_keys.
class UniqueTokenInApiKeys < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  COLUMN_NAME = :token
  TABLE_NAME = :api_keys

  # Remove unique index on token in api_keys
  #
  # @return [void]
  def down
    change_table TABLE_NAME do |t|
      t.remove_index COLUMN_NAME
    end
  end

  # Add unique index on token in api_keys after removing duplicates
  #
  # @return [void]
  def up
    # Delete duplicate rows that won't pass `index :token, unique => true` by taking the row with the highest
    # id
    #
    # @see http://stackoverflow.com/a/4442825
    execute "DELETE FROM api_keys " \
            "USING api_keys AS keep_api_keys " \
            "WHERE api_keys.token = keep_api_keys.token AND " \
                  "api_keys.id < keep_api_keys.id"

    change_table TABLE_NAME do |t|
      t.index COLUMN_NAME, :unique => true
    end
  end
end
