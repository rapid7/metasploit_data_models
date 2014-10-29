class Mdm::HostDetail < ActiveRecord::Base
  #
  # Associations
  #

  belongs_to :host,
             class_name: 'Mdm::Host',
             counter_cache: :host_detail_count,
             inverse_of: :host_details

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :src, :nx_site_name, :nx_site_importance, :nx_scan_template
                  :nx_risk_score
  
  # Foreign Keys
  
  attr_accessible :host_id, :nx_console_id, :nx_device_id
  
  # Model Associations
  
  attr_accessible :host
  
  #
  # Validations
  #

  validates :host_id, :presence => true

  Metasploit::Concern.run(self)
end
