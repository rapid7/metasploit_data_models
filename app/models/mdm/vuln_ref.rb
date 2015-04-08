class Mdm::VulnRef < ActiveRecord::Base
  self.table_name = 'vulns_refs'

  #
  # Associations
  #

  belongs_to :ref,
             class_name: 'Mdm::Ref',
             inverse_of: :vulns_refs

  belongs_to :vuln,
             class_name: 'Mdm::Vuln',
             inverse_of: :vulns_refs

  #
  # Mass Assignment Security
  #

  # Foreign Keys

  attr_accessible :ref_id, :vuln_id

  # Model Associations

  attr_accessible :ref, :vuln

  Metasploit::Concern.run(self)
end

