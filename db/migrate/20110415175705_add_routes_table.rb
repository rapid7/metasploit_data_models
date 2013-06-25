# Creates routes.
class AddRoutesTable < ActiveRecord::Migration
  # Drops routes and restores sessions.routes.
  #
  # @return [void]
	def down
		drop_table :routes

		add_column :sessions, :routes, :string
  end

  # Creates routes and removes sessions.routes.
  #
  # @return [void]
  def up
    create_table :routes do |t|
      t.integer :session_id
      t.string  :subnet
      t.string  :netmask
    end

    remove_column :sessions, :routes
  end
end
