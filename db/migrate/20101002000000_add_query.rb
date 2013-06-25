# Adds query to web_forms and web_vulns.
class AddQuery < ActiveRecord::Migration
  # Adds web_forms.query and web_vulns.query.
  #
  # @return [void]
  def down
    remove_column :web_forms, :query
    remove_column :web_vulns, :query
  end

  # Removes web_forms.query and web_vulns.query.
  #
  # @return [void]
  def up
    add_column :web_forms, :query, :text
    add_column :web_vulns, :query, :text
  end
end
