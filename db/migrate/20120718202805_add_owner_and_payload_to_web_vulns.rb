class AddOwnerAndPayloadToWebVulns < ActiveRecord::Migration[4.2]

  def self.up
    add_column :web_vulns, :owner,   :string
    add_column :web_vulns, :payload, :text
  end

  def self.down
    remove_column :web_vulns, :owner
    remove_column :web_vulns, :payload
  end

end
