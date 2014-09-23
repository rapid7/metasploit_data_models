class Mdm::HostDetail < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :src, :nx_site_name, :nx_site_importance, :nx_scan_template, 
                  :nx_risk_score
  
  #
  # Relations
  #

  belongs_to :host,
             class_name: 'Mdm::Host',
             counter_cache: :host_detail_count,
             inverse_of: :host_details

  #
  # Validations
  #

  validates :host_id, :presence => true

  Metasploit::Concern.run(self)
end
