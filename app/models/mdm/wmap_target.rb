class Mdm::WmapTarget < ActiveRecord::Base
  Metasploit::Concern.run(self)

  #
  # Attributes
  #

  # @!attribute [rw] address
  #   The IP address for this target. Necessary to avoid coercion to an `IPAddr` object.
  #
  #   @return [String]
  composed_of :address,
              class_name: 'String',
              mapping: %w(address to_s),
              constructor: Proc.new { |address| address.to_s }
end
