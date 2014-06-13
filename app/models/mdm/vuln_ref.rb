class Mdm::VulnRef < ActiveRecord::Base
  self.table_name = 'vulns_refs'

  #
  # Relations
  #

  belongs_to :ref,
             class_name: 'Mdm::Ref',
             inverse_of: :vulns_refs

  belongs_to :vuln,
             class_name: 'Mdm::Vuln',
             inverse_of: :vulns_refs

  ActiveSupport.run_load_hooks(:mdm_vuln_ref, self)
end

