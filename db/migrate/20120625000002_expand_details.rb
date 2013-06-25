# Adds host_details.src, vuln_details.nx_proof_key, vuln_details.nx_vuln_status, and vuln_details.src.
class ExpandDetails < ActiveRecord::Migration
  # Removes host_details.src, vuln_details.nx_proof_key, vuln_details.nx_vuln_status, and vuln_details.src.
  #
  # @return [void]
  def down
    remove_column :vuln_details, :nx_vuln_status
    remove_column :vuln_details, :nx_proof_key
    remove_column :vuln_details, :src
    remove_column :host_details, :src
  end

  # Adds host_details.src, vuln_details.nx_proof_key, vuln_details.nx_vuln_status, and vuln_details.src.
  #
  # @return [void]
  def up
    add_column :vuln_details, :nx_vuln_status, :text
    add_column :vuln_details, :nx_proof_key, :text
    add_column :vuln_details, :src, :string
    add_column :host_details, :src, :string
  end
end
