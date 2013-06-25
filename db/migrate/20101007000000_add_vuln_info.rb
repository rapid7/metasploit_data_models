# Adds blame, category, confidence, and description to web_vulns.
class AddVulnInfo < ActiveRecord::Migration
  # Adds web_vulns.blame, web_vulns.category, web_vulns.confidence, and web_vulns.description.
  #
  # @return [void]
  def down
    remove_column :web_forms, :category
    remove_column :web_vulns, :confidence
    remove_column :web_vulns, :description
    remove_column :web_vulns, :blame
  end

  # Adds web_vulns.blame, web_vulns.category, web_vulns.confidence, and web_vulns.description.
  #
  # @return [void]
  def up
    add_column :web_vulns, :category, :text
    add_column :web_vulns, :confidence, :text
    add_column :web_vulns, :description, :text
    add_column :web_vulns, :blame, :text
  end
end

