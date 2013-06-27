# Network route that goes through a {#session} to allow accessing IPs on the remote end of the session.
class Mdm::Route < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] session
  #   The session over which this route traverses.
  #
  #   @return [Mdm::Session]
  belongs_to :session, :class_name => 'Mdm::Session'

  #
  # Attributes
  #

  # @!attribute [rw] netmask
  #   The netmask for this route.
  #
  #   @return [String]

  # @!attribute [rw] subnet
  #   The subnet for this route.
  #
  #   @return [String]

  ActiveSupport.run_load_hooks(:mdm_route, self)
end
