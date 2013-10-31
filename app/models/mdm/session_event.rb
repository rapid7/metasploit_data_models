# Events that occurred when using a {#session}.
class Mdm::SessionEvent < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] session
  #   The session in which the event occured.
  #
  #   @return [Mdm::Session]
  belongs_to :session, class_name: 'Mdm::Session', inverse_of: :events

  # @!attribute [rw] command
  #   The command that was run through the session that triggered this event.
  #
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this event occurred.
  #
  #   @return [DateTime]

  # @!attribute [rw] etype
  #   The type of the event.
  #
  #   @return [String]

  # @!attribute [rw] local_path
  #   The current local directory when {#command} was run.
  #
  #   @return [String]

  # @!attribute [rw] output
  #   The {#output} of running {#command}.
  #
  #   @return [String]

  # @!attribute [rw] remote_path
  #   The current remote directory when {#command} was run.
  #
  #   @return [Stirng]

  ActiveSupport.run_load_hooks(:mdm_session_event, self)
end
