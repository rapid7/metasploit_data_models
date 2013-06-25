# Adds owner and payload to web_vulns.
class AddOwnerAndPayloadToWebVulns < ActiveRecord::Migration
  # Removes web_vulns.owner and web_vulns.payload.
  #
  # @return [void]
  def down
    remove_column :web_vulns, :owner
    remove_column :web_vulns, :payload
  end

  # Adds web_vulns.owner and web_vulns.payload.
  #
  # @return [void]
  def up
    add_column :web_vulns, :owner,   :string
    add_column :web_vulns, :payload, :text
  end
end
