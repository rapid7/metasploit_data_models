class Mdm::VulnDetail < ActiveRecord::Base
  
  #
  # Associations
  #

  belongs_to :nexpose_console,
             class_name: 'Mdm::NexposeConsole',
             inverse_of: :vuln_details

  belongs_to :vuln,
             class_name: 'Mdm::Vuln',
             counter_cache: :vuln_detail_count,
             inverse_of: :vuln_details

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :cvss_score, :cvss_vector, :title, :description, :solution,
                  :proof, :nx_severity, :nx_pci_severity, :nx_published,
                  :nx_added, :nx_modified, :nx_tags, :nx_vuln_status,
                  :nx_proof_key, :src, :nx_vulnerable_since,
                  :nx_pci_compliance_status
  
  # Foreign Keys
  
  attr_accessible :vuln_id, :nx_console_id, :nx_device_id, :nx_vuln_id,
                  :nx_scan_id
  
  # Model Associations
  
  attr_accessible :nexpose_console, :vuln
  
  #
  # Validations
  #

  validates :vuln_id, :presence => true

  Metasploit::Concern.run(self)
end
