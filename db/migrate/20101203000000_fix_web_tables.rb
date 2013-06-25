# Adds request to web_pages and web_vulns.
class FixWebTables < ActiveRecord::Migration
  # Removes web_pages.request and web_vulns.request.
  #
  # @return [void]
  def down
    # @todo Figure out why the change_column is indicated here and in {#up}.
    change_column :web_pages, :path, :text
    change_column :web_pages, :query, :text
    change_column :web_pages, :cookie, :text
    change_column :web_pages, :auth, :text
    change_column :web_pages, :ctype, :text
    change_column :web_pages, :location, :text
    change_column :web_pages, :path, :text
    change_column :web_vulns, :path, :text
    change_column :web_vulns, :pname, :text

    remove_column :web_pages, :request
    remove_column :web_vulns, :request
  end

  # Adds web_pages.request and web_vulns.request.
  #
  # @return [void]
	def up
    # @todo Figure out why the change_column is indicated here and in {#down}.
		change_column :web_pages, :path, :text
		change_column :web_pages, :query, :text
		change_column :web_pages, :cookie, :text
		change_column :web_pages, :auth, :text
		change_column :web_pages, :ctype, :text
		change_column :web_pages, :location, :text
		change_column :web_pages, :path, :text
		change_column :web_vulns, :path, :text
		change_column :web_vulns, :pname, :text
		
		add_column :web_pages, :request, :text
		add_column :web_vulns, :request, :text				
	end
end


