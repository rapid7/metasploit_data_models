class Mdm::WmapTarget < ActiveRecord::Base
  Metasploit::Concern.run(self)

  #
  # Attributes
  #

  # @!attribute [rw] address
  #   The IP address for this target. Necessary to avoid coercion to an `IPAddr` object.
  #
  #   @return [String]
  def address
    self[:address].to_s
  end
end
