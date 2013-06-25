# Raises limit on events.info, hosts.info, notes.data, services.info, and vulns.data to 4k.
class ExpandInfo < ActiveRecord::Migration
  # Restores old 1k limit on events.info, hosts.info, notes.data, services.info, and vulns.data.
  #
  # @return [void]
  def down
    remove_column :events, :info
    change_table :events do |t|
      t.string    :info
    end

    remove_column :notes, :data
    change_table :notes do |t|
      t.string    :data, :limit => 1024
    end

    remove_column :hosts, :info
    change_table :hosts do |t|
      t.string    :info, :limit => 1024
    end

    remove_column :vulns, :data
    change_table :hosts do |t|
      t.string    :data, :limit => 1024
    end

    remove_column :services, :info
    change_table :services do |t|
      t.string    :info, :limit => 1024
    end
  end

  # Raises limit on events.info, hosts.info, notes.data, services.info, and vulns.data to 4k.
  #
  # @return [void]
  def up
    remove_column :events, :info
    change_table :events do |t|
      t.string    :info, :limit => 4096
    end

    remove_column :notes, :data
    change_table :notes do |t|
      t.string    :data, :limit => 4096
    end

    remove_column :vulns, :data
    change_table :vulns do |t|
      t.string    :data, :limit => 4096
    end

    remove_column :hosts, :info
    change_table :hosts do |t|
      t.string    :info, :limit => 4096
    end

    remove_column :services, :info
    change_table :services do |t|
      t.string    :info, :limit => 4096
    end
  end
end

