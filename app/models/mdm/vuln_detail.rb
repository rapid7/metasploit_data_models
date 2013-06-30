# {Mdm::Vuln Vulnerability details} supplied from an external source, such as Nexpose.
class Mdm::VulnDetail < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] vuln
  #   The vulnerability this detail is about.
  #
  #   @return [Mdm::Vuln]
  belongs_to :vuln, :class_name => 'Mdm::Vuln', :counter_cache => :vuln_detail_count

  #
  #
  # Attributes
  #
  #

  # @!attribute [rw] description
  #   Long description of this vulnerability.
  #
  #   @return [String]

  # @!attribute [rw] src
  #   Source of this vulnerability detail.
  #
  #   @return [String]

  # @!attribute [rw] title
  #   Title of this vulnerability.
  #
  #   @return [String]

  # @!attribute [rw] proof
  #   Proof of this vulnerability existing on the target.
  #
  #   @return [String]

  # @!attribute [rw] solution
  #   Solution to fix this vulnerability.
  #
  #   @return [String]

  #
  # @!group Common Vulnerability Scoring System
  #

  # @!attribute [rw] cvss_score
  #   Composite Common Vulnerability Scoring System (CVSS) Score
  #
  #   @return [Float]

  # @!attribute [rw] cvss_vector
  #   {#cvss_score} broken down into its encoded components
  #
  #   @return [String]
  #   @see http://nvd.nist.gov/cvss.cfm?vectorinfo

  #
  # @!endgroup
  #

  #
  # @!group Nexpose
  #

  # association is declared here so it can be in Nexpose group

  # @!attribute [rw] nexpose_console
  #   The Nexpose console that supplied this information.
  #
  #   @return [Mdm::NexposeConsole]
  belongs_to :nexpose_console, :class_name => 'Mdm::NexposeConsole', :foreign_key => :nx_console_id

  # @!attribute [rw] nx_added
  #   When this vulnerability was added in Nexpose.
  #
  #   @return [DateTime]

  # @!attribute [rw] nx_device_id
  #   ID of target device in Nexpose.
  #
  #   @return [Integer]

  # @!attribute [rw] nx_modified
  #   The last time this vulnerability was modified in Nexpose.
  #
  #   @return [DateTime]

  # @!attribute [rw] nx_proof_key
  #   Key to {#proof} in Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_published
  #   When this vulnerability was published according to Nexpose.
  #
  #   @return [DateTime]

  # @!attribute [rw] nx_scan_id
  #   ID of scan that found this vulnerability in Nexpose.
  #
  #   @return [Integer]

  # @!attribute [rw] nx_tags
  #   Tags on this vulnerability in Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_vuln_id
  #   ID of this vulnerability in Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_vuln_status
  #   Status of this vulnerability in Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_vulnerable_since
  #   When this vulnerability was first identified for the target in Nexpose.
  #
  #   @return [DateTime]

  # @!attribute [rw] nx_severity
  #   Severity of this vulnerability according to Nexpose.
  #
  #   @return [Float]

  #
  # @!endgroup
  #

  #
  # @!group Nexpose PCI
  #

  # @!attribute [rw] nx_pci_compliance_status
  #   Status of PCI compliance with regards to this vulnerability according to Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_pci_severity
  #   The severity for the vulnerability under PCI according to Nexpose.
  #
  #   @return [Float]

  #
  # @!endgroup
  #

  #
  # Validations
  #

  validates :vuln_id, :presence => true

  ActiveSupport.run_load_hooks(:mdm_vuln_detail, self)
end
