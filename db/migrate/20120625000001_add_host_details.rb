# Creates host_details.
class AddHostDetails < ActiveRecord::Migration
  # Drops host_details.
  #
  # @return [void]
	def down
		drop_table :host_details
  end

  # Creates host_details.
  #
  # @return [void]
  def up
		create_table :host_details do |t|
			t.integer   :host_id     # Host table reference

			# Nexpose-specific fields
			t.integer	:nx_console_id   # NexposeConsole table reference
			t.integer	:nx_device_id    # Reference from the Nexpose side
		end
	end
end
