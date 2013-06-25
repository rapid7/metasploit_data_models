# Creates web_forms, web_pages, web_sites, and web_vulns.
class AddWebTables < ActiveRecord::Migration
  # Drops web_forms, web_pages, web_sites, and web_vulns.
  #
  # @return [void]
  def down
    drop_table :web_sites
    drop_table :web_pages
    drop_table :web_forms
    drop_table :web_vulns
  end

  # Creates web_forms, web_pages, web_sites, and web_vulns.
  #
  # @return [void]
	def up
		create_table :web_sites do |t|
			t.integer   :service_id, :null => false
			t.timestamps 
			t.string    :vhost, :limit => 2048
			t.text      :comments
			t.text      :options
		end
		
		create_table :web_pages do |t|
			t.integer   :web_site_id, :null => false
			t.timestamps 
			t.text      :path
			t.text      :query
			t.integer   :code, :null => false
			t.text      :cookie
			t.text      :auth
			t.text      :ctype
			t.timestamp :mtime				
			t.text      :location
			t.text      :body
			t.text      :headers
		end	

		create_table :web_forms do |t|
			t.integer   :web_site_id, :null => false
			t.timestamps 
			t.text      :path
			t.string    :method, :limit => 1024
			t.text      :params
		end	

		create_table :web_vulns do |t|
			t.integer   :web_site_id, :null => false
			t.timestamps 
			t.text      :path
			t.string    :method, :limit => 1024
			t.text      :params
			t.text      :pname
			t.text      :proof
			t.integer   :risk
			t.string    :name,    :limit => 1024	
		end	
  end
end


