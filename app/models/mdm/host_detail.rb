class Mdm::HostDetail < ActiveRecord::Base
  #
  # Associations
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
