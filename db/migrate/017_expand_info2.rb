# Increases limit of events.info, hosts.info, notes.data, services.info, vulns.data to 64k.  Removes any old data in
# those columns in the process.
class ExpandInfo2 < ActiveRecord::Migration
  # Restores old 4k limit of events.info, hosts.info, notes.data, services.info, vulns.data.  Removes any old data in
  # those columns in the process.
  #
  # @return [void]
  def down
    remove_column :events, :info
    change_table :events do |t|
      t.string    :info
    end

    remove_column :notes, :data
    change_table :notes do |t|
      t.string    :data, :limit => 4096
    end

    remove_column :hosts, :info
    change_table :hosts do |t|
      t.string    :info, :limit => 4096
    end

    remove_column :vulns, :data
    change_table :vulns do |t|
      t.string    :data, :limit => 4096
    end

    remove_column :services, :info
    change_table :services do |t|
      t.string    :info, :limit => 4096
    end
  end

  # Increases limit of events.info, hosts.info, notes.data, services.info, vulns.data to 64k.  Removes any old data in
  # those columns in the process.
  #
  # @return [void]
  def up
    remove_column :events, :info
    change_table :events do |t|
      t.string    :info, :limit => 65536
    end

    remove_column :notes, :data
    change_table :notes do |t|
      t.string    :data, :limit => 65536
    end

    remove_column :vulns, :data
    change_table :vulns do |t|
      t.string    :data, :limit => 65536
    end

    remove_column :hosts, :info
    change_table :hosts do |t|
      t.string    :info, :limit => 65536
    end

    remove_column :services, :info
    change_table :services do |t|
      t.string    :info, :limit => 65536
    end
  end
end

