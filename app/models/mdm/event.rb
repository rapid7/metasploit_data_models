# Records framework events to the database.
class Mdm::Event < ActiveRecord::Base
  #
  # Associations
  # @todo https://www.pivotaltracker.com/story/show/52193783
  # @todo https://www.pivotaltracker.com/story/show/52193911
  #

  # @!attribute [rw] host
  #   Host on which this event occurred.
  #
  #   @return [Mdm::Host]
  #   @return [nil] if event did not occur on a host.
  belongs_to :host, :class_name => 'Mdm::Host'

  # @!attribute [rw] workspace
  #   Workspace in which this event occured.  If {#host} is present, then this will match
  #   {Mdm::Host#workspace `host.workspace`}.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace, :class_name => 'Mdm::Workspace'

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this event was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] critical
  #   Indicates if the event is critical.
  #
  #   @return [false] event is not critical.
  #   @return [true] event is critical.

  # @!attribute [rw] name
  #   Name of the event, such as 'module_run'.
  #
  #   @return [String]

  # @!attribute [rw] seen
  #   Whether a user has seen these events.
  #
  #   @return [false] if the event has not been seen.
  #   @return [true] if any user has seen the event.

  # @!attribute [rw] updated_at
  #   The last time this event was updated.
  #
  #   @return [DateTime]

  # @!attribute [rw] username
  #   Name of user that triggered the event.  Not necessarily a {Mdm::User#username}, as {#username} may be set to
  #   the username of the user inferred from `ENV` when using metasploit-framework.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52193783

  #
  # Scopes
  #

  #
  # @!group Scopes
  #

  # @!method self.flagged
  #   Critical, unseen events.
  #
  #   @return [ActiveRecord::Relation]
  scope :flagged, where(:critical => true, :seen => false)

  # @!method self.module_run
  #   Module run events.
  #
  #   @return [ActiveRecord::Relation]
  scope :module_run, where(:name => 'module_run')

  #
  # @!endgroup
  #

  #
  # Serializations
  #

  # {#name}-specific information about this event.
  #
  # @return [Hash]
  # @todo https://www.pivotaltracker.com/story/show/52193911
  serialize :info, MetasploitDataModels::Base64Serializer.new

  #
  # Validations
  #

  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_event, self)
end

