# Request sent to a {Mdm::WmapTarget}.  WMAP is a plugin to metasploit-framework.
#
# @deprecated use the Mdm::Web* models instead.
# @todo https://www.pivotaltracker.com/story/show/52632361
class Mdm::WmapRequest < ActiveRecord::Base
  #
  #
  # Attributes
  #
  #

  # @!attribute [rw] address
  #   IP address of {#host} to which this request was sent.
  #
  #   @return [String]

  # @!attribute [rw] body
  #   Body of this request.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this request was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] headers
  #   Headers sent as part of this request.
  #
  #   @return [String]

  # @!attribute [rw] host
  #   Name of host to which this request was sent.
  #
  #   @return [String]

  # @!attribute [rw] meth
  #   HTTP Method (or VERB) used for request.
  #
  #   @return [String]

  # @!attribute [rw] path
  #   Path portion of URL for this request.
  #
  #   @return [String]

  # @!attribute [rw] port
  #   Port at {#address} to which this request was sent.
  #
  #   @return [Integer]

  # @!attribute [rw] query
  #   Query portion of URL for this request.
  #
  #   @return [String]

  # @!attribute [rw] ssl
  #   Version of SSL to use.
  #
  #   @return [Integer]

  # @!attribute [rw] updated_at
  #   The last time this request was updated.
  #
  #   @return [DateTime]

  #
  # @!group Response
  #

  # @!attribute [rw] respcode
  #   HTTP status code sent in response to this request from server.
  #
  #   @return [String]

  # @!attribute [rw] resphead
  #   Headers sent in response from server.
  #
  #   @return [String]

  # @!attribute [rw] response
  #   Response sent from server.
  #
  #   @return [String]

  #
  # @!endgroup
  #

  ActiveSupport.run_load_hooks(:mdm_wmap_request, self)
end
