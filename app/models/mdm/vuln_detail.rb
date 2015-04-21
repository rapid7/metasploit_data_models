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
  # Validations
  #

  validates :vuln_id, :presence => true

  Metasploit::Concern.run(self)
end
