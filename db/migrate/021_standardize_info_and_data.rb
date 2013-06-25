# Standardizes on type-specific data being in info column for vulns table.
class StandardizeInfoAndData < ActiveRecord::Migration
  # Removes vulns.info and restores vulns.data.  Data is lost in the process.
  #
  # @return [void]
  def down
    remove_column :vulns, :info

    change_table :vulns do |t|
      t.string :data, :limit => 65536
    end
  end

  # Removes vulns.data and adds vulns.info.  Data is lost in the process.
  #
  # @return [void]
  def up
    # Remove the host requirement.  We'll add the column back in below.
    remove_column :vulns, :data

    change_table :vulns do |t|
      t.string :info, :limit => 65536
    end
  end
end

