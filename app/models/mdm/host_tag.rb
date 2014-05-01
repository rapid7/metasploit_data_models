class Mdm::HostTag < ActiveRecord::Base
  self.table_name = "hosts_tags"

  #
  # Relations
  #

  # @!attribute host
  #   Host with {#tag}.
  #
  #   @todo MSP-2723
  #   @return [Mdm::Host]
  belongs_to :host,
             class_name: 'Mdm::Host',
             inverse_of: :hosts_tags

  # @!attribute tag
  #   Tag on {#host}.
  #
  #   @todo MSP-2723
  #   @return [Mdm::Tag]
  belongs_to :tag,
             class_name: 'Mdm::Tag',
             inverse_of: :hosts_tags

  ActiveSupport.run_load_hooks(:mdm_host_tag, self)
end

