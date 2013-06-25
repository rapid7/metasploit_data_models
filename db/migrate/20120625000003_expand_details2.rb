# Adds host_details.nx_risk_score, host_details.nx_scan_template, host_details.nx_site_importance,
# host_details.nx_site_name, vuln_details.nx_pci_compliance_status, vuln_details.nx_scan_id, and
# vuln_details.nx_vulnerable_since.
class ExpandDetails2 < ActiveRecord::Migration
  # Removes host_details.nx_risk_score, host_details.nx_scan_template, host_details.nx_site_importance,
  # host_details.nx_site_name, vuln_details.nx_pci_compliance_status, vuln_details.nx_scan_id, and
  # vuln_details.nx_vulnerable_since.
  #
  # @return [void]
  def down
    remove_column :host_details, :nx_site_name
    remove_column :host_details, :nx_site_importance
    remove_column :host_details, :nx_scan_template
    remove_column :host_details, :nx_risk_score

    remove_column :vuln_details, :nx_scan_id
    remove_column :vuln_details, :nx_vulnerable_since
    remove_column :vuln_details, :nx_pci_compliance_status
  end

  # Adds host_details.nx_risk_score, host_details.nx_scan_template, host_details.nx_site_importance,
  # host_details.nx_site_name, vuln_details.nx_pci_compliance_status, vuln_details.nx_scan_id, and
  # vuln_details.nx_vulnerable_since.
  #
  # @return [void]
  def up
    add_column :host_details, :nx_site_name, :string
    add_column :host_details, :nx_site_importance, :string
    add_column :host_details, :nx_scan_template, :string
    add_column :host_details, :nx_risk_score, :float

    add_column :vuln_details, :nx_scan_id, :integer
    add_column :vuln_details, :nx_vulnerable_since, :timestamp
    add_column :vuln_details, :nx_pci_compliance_status, :string
  end
end
