# @deprecated New style SocialEngineering campaigns are Pro-only models.
# @todo https://www.pivotaltracker.com/story/show/52149851
class Mdm::Client < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] host
  #   Host from which this client connected.
  #
  #   @return [Mdm::Host]
  belongs_to :host, class_name: 'Mdm::Host', inverse_of: :clients

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this client was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] updated_at
  #   When this client was last updated.
  #
  #   @return [DateTime]

  #
  # @!group User Agent
  #

  # @!attribute [rw] ua_name
  #   Parsed name from {#ua_string user agent string}
  #
  #   @return [String]

  # @!attribute [rw] ua_string
  #   Raw user agent string from client browser
  #
  #   @return [String]

  # @!attribute [rw] ua_ver
  #   Version of user agent.
  #
  #   @return [String]

  #
  # @!endgroup
  #

  ActiveSupport.run_load_hooks(:mdm_client, self)
end
