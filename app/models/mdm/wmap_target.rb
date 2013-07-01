# WMAP target. WMAP is a plugin to metasploit-framework.
#
# @deprecated use the Mdm::Web* models instead.
# @todo https://www.pivotaltracker.com/story/show/52632361
class Mdm::WmapTarget < ActiveRecord::Base
  #
  # Attributes
  #

  # @!attribute [rw] address
  #   IP address of {#host}.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this target was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] host
  #   Name of this target.
  #
  #   @return [String]

  # @!attribute [rw] port
  #   Port on this target to send {Mdm::WmapRequest requests}.
  #
  #   @return [Integer]

  # @!attribute [rw] selected
  #   Whether this target should be sent requests.
  #
  #   @return [Integer]

  # @!attribute [rw] ssl
  #   Version of SSL to use when sending requests to this target.
  #
  #   @return [Integer]

  # @!attribute [rw] updated_at
  #   The last time this target was updated.
  #
  #   @return [DateTime]

  ActiveSupport.run_load_hooks(:mdm_wmap_target, self)
end
