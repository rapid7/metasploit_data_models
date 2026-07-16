# One invocation of one Metasploit module (or one direct-write
# pseudo-execution. Captures the full forensic record so every
# artifact a module produces or touches can be traced back to a single
# row in `module_executions`.
class Mdm::ModuleExecution < ApplicationRecord
  self.table_name = 'module_executions'

  #
  # CONSTANTS
  #

  # Why the module was run. `direct_write` is used when an external
  # workflow inserts artifacts (hosts, services, creds, loot, ...)
  # without invoking a module via the framework.
  KINDS = %w[run check import direct_write].freeze

  # Module types as exposed by Framework.
  MODULE_TYPES = %w[exploit auxiliary post payload encoder evasion nop].freeze

  # User interface or programmatic surface that initiated this execution.
  ORIGINATING_INTERFACES = %w[console rpc json_rpc mcp external import plugin autocheck].freeze

  # Terminal lifecycle states. `running` is the only non-terminal value
  # and is permitted while {#ended_at} is `NULL`.
  TERMINAL_STATUSES = %w[running success neutral expected_failure unhandled_exception].freeze

  # Six-value enum published by `Msf::Exploit::CheckCode` for
  # {#check_code}. Only populated when {#kind} is `'check'`.
  CHECK_CODES = %w[vulnerable appears detected safe unknown unsupported].freeze

  #
  # Associations
  #

  # Workspace that owns this execution. All artifacts produced by the
  # execution share this workspace.
  #
  # @return [Mdm::Workspace]
  belongs_to :workspace,
             class_name: 'Mdm::Workspace',
             inverse_of: :module_executions

  # User who initiated this execution, when known. May be `nil` for
  # executions originating from non-authenticated surfaces or from
  # background workers without a session.
  #
  # @return [Mdm::User]
  # @return [nil] when no user is associated with this execution.
  belongs_to :originating_user,
             class_name: 'Mdm::User',
             optional: true,
             inverse_of: :module_executions

  # Parent execution that spawned this one (e.g. an exploit's auto-run
  # post module). Forms a tree of related executions when present.
  #
  # @return [Mdm::ModuleExecution]
  # @return [nil] for top-level executions.
  belongs_to :parent_execution,
             class_name: 'Mdm::ModuleExecution',
             optional: true,
             inverse_of: :children

  # Child executions spawned by this execution.
  #
  # @return [ActiveRecord::Relation<Mdm::ModuleExecution>]
  has_many :children,
           class_name: 'Mdm::ModuleExecution',
           foreign_key: :parent_execution_id,
           inverse_of: :parent_execution,
           dependent: :nullify

  # Errors raised within this execution. Renamed from `errors` to avoid
  # colliding with `ActiveModel::Validations#errors`.
  #
  # @return [ActiveRecord::Relation<Mdm::ModuleExecutionError>]
  has_many :execution_errors,
           class_name: 'Mdm::ModuleExecutionError',
           inverse_of: :module_execution,
           dependent: :destroy

  # Optional generalized timeline events recorded for this execution.
  #
  # @return [ActiveRecord::Relation<Mdm::ModuleExecutionEvent>]
  has_many :events,
           class_name: 'Mdm::ModuleExecutionEvent',
           inverse_of: :module_execution,
           dependent: :destroy

  #
  # Attributes
  #

  # @!attribute [rw] module_reference_name
  #   Reference name of the module that was executed, e.g.
  #   `auxiliary/scanner/smb/smb_version`.
  #
  #   @return [String]

  # @!attribute [rw] module_type
  #   One of {MODULE_TYPES}.
  #
  #   @return [String]

  # @!attribute [rw] kind
  #   One of {KINDS}. Defaults to `'run'`.
  #
  #   @return [String]

  # @!attribute [rw] options_snapshot
  #   The datastore options the module was invoked with
  #
  #   @return [Hash]
  #   @return [nil] when no options were captured.

  # @!attribute [rw] originating_interface
  #   One of {ORIGINATING_INTERFACES}.
  #
  #   @return [String]

  # @!attribute [rw] originating_token_ref
  #   Opaque reference to the auth token / API key used to authorize
  #   this execution, when applicable. Never the token itself.
  #
  #   @return [String]
  #   @return [nil] when not applicable.

  # @!attribute [rw] started_at
  #   Wall-clock time when the framework began running the module.
  #
  #   @return [DateTime]

  # @!attribute [rw] ended_at
  #   Wall-clock time when the module finished, regardless of outcome.
  #   Must be greater than or equal to {#started_at}.
  #
  #   @return [DateTime]
  #   @return [nil] while the execution is still running.

  # @!attribute [rw] terminal_status
  #   One of {TERMINAL_STATUSES}. Constrained to be `'running'` (or
  #   `nil`) while {#ended_at} is `nil`, and a non-`running` value
  #   once {#ended_at} is set.
  #
  #   @return [String]
  #   @return [nil] while the execution is still running.

  # @!attribute [rw] failure_reason
  #   Short coded reason describing why the module ended in a non-
  #   success terminal status (e.g. `'no-target'`,
  #   `'payload-not-supported'`).
  #
  #   @return [String]
  #   @return [nil] when the execution did not fail.

  # @!attribute [rw] failure_message
  #   Human-readable message describing the failure.
  #
  #   @return [String]
  #   @return [nil] when the execution did not fail.

  # @!attribute [rw] check_code
  #   The {CHECK_CODES} value returned by a `kind = 'check'` execution
  #   (i.e. `Msf::Exploit::CheckCode#code`). NULL for non-check
  #   executions, and NULL for check executions that raised before
  #   returning a `CheckCode`.
  #
  #   @return [String]
  #   @return [nil] when not populated.

  # @!attribute [rw] check_message
  #   Human-readable message that accompanies {#check_code} (i.e.
  #   `Msf::Exploit::CheckCode#message`). NULL when {#check_code} is
  #   NULL, and may be NULL even when {#check_code} is set if the
  #   check returned no message.
  #
  #   @return [String]
  #   @return [nil] when not populated.

  # @!attribute [rw] single_entity_failure_count
  #   How many individually-failed entities (e.g. hosts in a scanner)
  #   the module recorded during this execution. Used to surface
  #   per-entity failure summaries without listing every error row.
  #
  #   @return [Integer]
  #   @return [0] when no per-entity failures were recorded.

  # @!attribute [rw] last_single_entity_errors
  #   Capped sample of the most recent per-entity error
  #   summaries, suitable for quick inspection in the UI.
  #
  #   @return [Array<Hash>]
  #   @return [nil] when no per-entity errors were recorded.

  # @!attribute [rw] created_at
  #   When this execution row was inserted.
  #
  #   @return [DateTime]

  # @!attribute [rw] updated_at
  #   Last time this execution row was updated.
  #
  #   @return [DateTime]

  #
  # Validations
  #

  validates :module_reference_name, presence: true
  validates :module_type,    presence: true, inclusion: { in: MODULE_TYPES }
  validates :kind,           presence: true, inclusion: { in: KINDS }
  validates :originating_interface, presence: true, inclusion: { in: ORIGINATING_INTERFACES }
  validates :terminal_status, inclusion: { in: TERMINAL_STATUSES, allow_nil: true }
  validates :check_code, inclusion: { in: CHECK_CODES, allow_nil: true }
  validates :started_at, presence: true
  validates :single_entity_failure_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :ended_at_not_before_started_at
  validate :terminal_status_consistent_with_ended_at
  validate :check_code_only_on_check_kind

  Metasploit::Concern.run(self)

  private

  def ended_at_not_before_started_at
    return if ended_at.blank? || started_at.blank?
    return if ended_at >= started_at

    errors.add(:ended_at, 'must be greater than or equal to started_at')
  end

  def terminal_status_consistent_with_ended_at
    if ended_at.nil?
      return if terminal_status.nil? || terminal_status == 'running'

      errors.add(:terminal_status, "must be 'running' or blank while ended_at is NULL")
    elsif terminal_status.nil? || terminal_status == 'running'
      errors.add(:terminal_status, 'must be a terminal value once ended_at is set')
    end
  end

  def check_code_only_on_check_kind
    return if kind == 'check'
    return if check_code.nil? && check_message.nil?

    errors.add(:check_code, 'may only be populated when kind is check') unless check_code.nil?
    errors.add(:check_message, 'may only be populated when kind is check') unless check_message.nil?
  end
end
