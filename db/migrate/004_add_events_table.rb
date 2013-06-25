# Creates events.
class AddEventsTable < ActiveRecord::Migration
  # Drops events.
  #
  # @return [void]
  def down
    drop_table :events
  end

  # Creates events.
  #
  # @return [void]
  def up
    create_table :events do |t|
      t.integer   :workspace_id
      t.integer   :host_id
      t.timestamp :created_at
      t.string    :user
      t.string    :name
      t.string    :info
    end
  end
end

