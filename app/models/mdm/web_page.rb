# Web page requested from a {#web_site}.
class Mdm::WebPage < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] web_site
  #   {Mdm::WebSite Web site} from which this page was requested.
  #
  #   @return [Mdm::WebSite]
  belongs_to :web_site, :class_name => 'Mdm::WebSite'

  #
  # Attributes
  #

  # @!attribute [rw] auth
  #   Credentials sent to server to authenticate to web site to allow access to this web page.
  #
  #   @return [String]

  # @!attribute [rw] body
  #   Body of response from server.
  #
  #   @return [String]

  # @!attribute [rw] code
  #   HTTP Status code return from {#web_site} when requesting this web page.
  #
  #   @return [Integer]

  # @!attribute [rw] cookie
  #   Cookies derived from {#headers}.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this web page was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] ctype
  #   The content type derived from the {#headers} of the returned web page.
  #
  #   @return [String]

  # @!attribute [rw] location
  #   Location derived from {#headers}.
  #
  #   @return [String]

  # @!attribute [rw] mtime
  #   The last modified time of the web page derived from the {#headers}.
  #
  #   @return [DateTime]

  # @!attribute [rw] path
  #   Path portion of URL that was used to access this web page.
  #
  #   @return [String]

  # @!attribute [rw] query
  #   Query portion of URLthat was used to access this web page.
  #
  #   @return [String]

  # @!attribute [rw] request
  #   Request sent to server to cause this web page to be returned.
  #
  #   @return [String]

  # @!attribute [rw] updated_at
  #   The last time this web page was updated.
  #
  #   @return [DateTime]

  #
  # Serializations
  #

  # @!attribute [rw] headers
  #   Headers sent from server.
  #
  #   @return [Hash{String => String}]
  serialize :headers, MetasploitDataModels::Base64Serializer.new

  ActiveSupport.run_load_hooks(:mdm_web_page, self)
end

