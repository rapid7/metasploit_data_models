# Creates wmap_requests and wmap_targets.
class AddWmapTables < ActiveRecord::Migration
  # Drops wmap_requests and wmap_targets.
  #
  # @return [void]
  def down
    drop_table :wmap_targets
    drop_table :wmap_requests
  end

  # Creates wmap_requests and wmap_targets.
  #
  # @return [void]
  def up
    create_table :wmap_targets do |t|
      t.string  :host                  # vhost
      t.string  :address, :limit => 16 # unique
      t.string  :address6
      t.integer :port
      t.integer :ssl
      t.integer :selected
    end

    create_table :wmap_requests do |t|
      t.string  :host                  # vhost
      t.string  :address, :limit => 16 # unique
      t.string  :address6
      t.integer :port
      t.integer :ssl
      t.string  :meth, :limit => 32
      t.text    :path
      t.text    :headers
      t.text    :query
      t.text    :body
      t.string  :respcode, :limit => 16
      t.text    :resphead
      t.text    :response
      t.timestamp :created
    end
  end
end

