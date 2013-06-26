# Details supplied by Nexpose about a {Mdm::Host host}.
class Mdm::HostDetail < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] host
  #   Host that this detail is about.
  #
  #   @return [Mdm::Host]
  belongs_to :host, :class_name => 'Mdm::Host', :counter_cache => :host_detail_count

  #
  # Attributes
  #

  # @!attribute [rw] nx_console_id
  #   The ID of the Nexpose console.
  #
  #   @return [Integer]

  # @!attribute [rw] nx_device_id
  #   The ID of the Device in Nexpose.
  #
  #   @return [Integer]

  # @!attribute [rw] nx_risk_score
  #   Risk score assigned by Nexpose.  Useful to ordering hosts to determine which host to target first in metasploit.
  #
  #   @return [Float]

  # @!attribute [rw] nx_scan_template
  #   The template used by Nexpose to perform the scan on the {#nx_site_name site} on {#host}.
  #
  #   @return [String]

  # @!attribute [rw] nx_site_importance
  #   The importance of scanning the {#nx_site_name site} running on {#host} according to Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] nx_site_name
  #   Name of site running on {#host} according to Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] src
  #    @return [String]
  #    @todo https://www.pivotaltracker.com/story/show/52399319

  #
  # Validations
  #

  validates :host_id, :presence => true

  ActiveSupport.run_load_hooks(:mdm_host_detail, self)
end
