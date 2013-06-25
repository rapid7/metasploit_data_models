# Add counter caches to hosts and vulns.
class AddVulnAndHostCounterCaches < ActiveRecord::Migration
  # Removes hosts.host_detail_count, vulns.vuln_attempt_count, and vulns.vuln_detail_count.
  #
  # @return [void]
  def down
    remove_column :hosts, :host_detail_count
    remove_column :vulns, :vuln_detail_count
    remove_column :vulns, :vuln_attempt_count
  end

  # Adds hosts.host_detail_count, vulns.vuln_attempt_count, and vulns.vuln_detail_count.
  #
  # @return [void]
  def up
    add_column :hosts, :host_detail_count, :integer, :default => 0
    add_column :vulns, :vuln_detail_count, :integer, :default => 0
    add_column :vulns, :vuln_attempt_count, :integer, :default => 0
  end
end
