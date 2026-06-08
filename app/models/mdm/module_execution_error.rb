# One row per unhandled exception or explicit failure raised within a
# {Mdm::ModuleExecution}. A single execution may produce many error rows
# when it touches multiple entities (e.g. one row per failed host in
# a scanner sweep).
class Mdm::ModuleExecutionError < ApplicationRecord
  self.table_name = 'module_execution_errors'

  #
  # CONSTANTS
  #

  # Lifecycle phases of a module run during which an error may be
  # captured. `run` covers auxiliary modules, the others map to the
  # exploit lifecycle (setup → check → exploit → cleanup) and the
  # post-exploitation pass.
  LIFECYCLE_PHASES = %w[setup check exploit cleanup post run].freeze

  #
  # Associations
  #

  # The module execution this error was raised within.
  #
  # @return [Mdm::ModuleExecution]
  belongs_to :module_execution,
             class_name: 'Mdm::ModuleExecution',
             inverse_of: :execution_errors

  #
  # Attributes
  #

  # @!attribute [rw] exception_class
  #   Fully-qualified Ruby class name of the exception, when the
  #   failure was raised as one (e.g. `'Rex::ConnectionError'`).
  #
  #   @return [String]
  #   @return [nil] when the failure was not raised via an exception.

  # @!attribute [rw] message
  #   Human-readable failure message.
  #
  #   @return [String]
  #   @return [nil] when no message was captured.

  # @!attribute [rw] backtrace
  #   Captured backtrace (newline-joined) at the point the error was
  #   recorded.
  #
  #   @return [String]
  #   @return [nil] when no backtrace was available.

  # @!attribute [rw] lifecycle_phase
  #   One of {LIFECYCLE_PHASES}.
  #
  #   @return [String]

  # @!attribute [rw] failure_reason
  #   Short coded reason classifying the failure (e.g.
  #   `'connection-refused'`, `'auth-failed'`).
  #
  #   @return [String]
  #   @return [nil] when the failure has no coded reason.

  # @!attribute [rw] occurred_at
  #   Wall-clock time the error was raised.
  #
  #   @return [DateTime]

  # @!attribute [rw] created_at
  #   When this error row was inserted.
  #
  #   @return [DateTime]

  # @!attribute [rw] updated_at
  #   Last time this error row was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :lifecycle_phase, presence: true, inclusion: { in: LIFECYCLE_PHASES }
  validates :occurred_at, presence: true

  Metasploit::Concern.run(self)
end
