# Adds counter caches to hosts.
class AddCounterCachesToHosts < ActiveRecord::Migration
  # Removes hosts.note_count, hosts.service_count, hosts.vuln_count.
  #
  # @return [void]
  def down
    remove_column :hosts, :note_count
    remove_column :hosts, :vuln_count
    remove_column :hosts, :service_count
  end

  # Adds hosts.note_count, hosts.service_count, and hosts.vuln_count.
  #
  # @return [void]
  def up
    add_column :hosts, :note_count, :integer, :default => 0
    add_column :hosts, :vuln_count, :integer, :default => 0
    add_column :hosts, :service_count, :integer, :default => 0

    Mdm::Host.reset_column_information
    Mdm::Host.all.each do |h|
      Mdm::Host.reset_counters h.id, :notes
      Mdm::Host.reset_counters h.id, :vulns
      Mdm::Host.reset_counters h.id, :services
    end
  end
end