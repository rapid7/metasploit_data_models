# Optional generalized timeline entry attached to a
# {Mdm::ModuleExecution}. Used to record milestones that aren't
# artifacts in their own right (e.g. `'session_opened'`,
# `'target_selected'`, `'check_returned'`).
class Mdm::ModuleExecutionEvent < ApplicationRecord
  self.table_name = 'module_execution_events'

  #
  # Associations
  #

  # The module execution this event belongs to.
  #
  # @return [Mdm::ModuleExecution]
  belongs_to :module_execution,
             class_name: 'Mdm::ModuleExecution',
             inverse_of: :events

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   Short identifier for the event, e.g. `'session_opened'`.
  #
  #   @return [String]

  # @!attribute [rw] payload
  #   Free-form structured data describing the event. Schema is
  #   per-event-name; consumers should treat unknown keys as opaque.
  #
  #   @return [Hash]
  #   @return [nil] when the event carries no structured payload.

  # @!attribute [rw] occurred_at
  #   Wall-clock time the event was emitted.
  #
  #   @return [DateTime]

  # @!attribute [rw] created_at
  #   When this event row was inserted.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :name, presence: true
  validates :occurred_at, presence: true

  Metasploit::Concern.run(self)
end
