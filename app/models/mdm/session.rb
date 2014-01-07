# A session opened on a {#host} using an {#via_exploit exploit} and controlled through a {#via_payload payload} to
# connect back to the local host using meterpreter or a cmd shell.
class Mdm::Session < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # @!attribute [rw] architecture
  #   Architecture of this session.  Not necessarily the same as the architecture of {Mdm::Host} as the {Mdm::Host} will
  #   normally have a CPU architecture like 'x86' while a session can have a programming language architecture like
  #   'ruby'.
  #
  #   @return [Mdm::Architecture]
  belongs_to :architecture, class_name: 'Mdm::Architecture', inverse_of: :sessions

  # @!attribute [rw] events
  #   Events that occurred when this session was open.
  #
  #   @return [Array<Mdm::Event>]
  has_many :events, class_name: 'Mdm::SessionEvent', dependent: :delete_all, inverse_of: :session, order: 'created_at'

  # @!attribute [rw] exploit_attempt
  #   Exploit attempt that created this session.
  #
  #   @return [Mdm::ExploitAttempt]
  has_one :exploit_attempt, class_name: 'Mdm::ExploitAttempt', inverse_of: :session

  # @!attribute [rw] exploit_class
  #   Exploit class that opened this session.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :exploit_class, class_name: 'Mdm::Module::Class', inverse_of: :exploit_sessions

  # @!attribute [rw] payload_class
  #   Payload class that was sent for this session.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :payload_class, class_name: 'Mdm::Module::Class', inverse_of: :payload_sessions

  # @!attribute [rw] host
  #   {Mdm::Host Host} on which this session was opened.
  #
  #   @return [Mdm::Host]
  belongs_to :host, class_name: 'Mdm::Host', inverse_of: :sessions

  # @!attribute [rw] platform
  #   The platform of this session.
  #
  #   @return [Mdm::Platform]
  belongs_to :platform, class_name: 'Mdm::Platform', inverse_of: :sessions

  # @!attribute [rw] routes
  #   Routes tunneled through this session.
  #
  #   @return [Array<Mdm::Route>]
  has_many :routes, class_name: 'Mdm::Route', dependent: :destroy, inverse_of: :session

  # @!attribute [rw] task_sessions
  #   Details about sessions this task touched
  #
  #   @return [Array<Mdm::TaskSession>]
  has_many :task_sessions, class_name: 'Mdm::TaskSession', dependent: :destroy, inverse_of: :session

  # @!attribute [rw] vuln_attempt
  #   Vulnerability attempt that created this session.
  #
  #   @return [Mdm::VulnAttempt]
  has_one :vuln_attempt, :class_name => 'Mdm::VulnAttempt', inverse_of: :session

  #
  # Through :host
  #

  # @!attribute [r] workspace
  #   The workspace in which this session exists.
  #
  #   @return [Mdm::Workspace]
  has_one :workspace, class_name: 'Mdm::Workspace', through: :host

  #
  # through: :task_sessions
  #

  # @!attribute [rw] task
  #   Session this task touched
  #
  #   @return [Mdm::Session]
  has_many :tasks, class_name: 'Mdm::Task', through: :task_sessions

  #
  # Attributes
  #

  # @!attribute [rw] closed_at
  #   When the session was closed on {#host}.
  #
  #   @return [DateTime]

  # @!attribute [rw] close_reason
  #   Why the session was closed.  Used to differentiate between user killing it local and the session being killed on
  #   the remote end.
  #
  #   @return [String]

  # @!attribute [rw] datastore
  #   Options for {#via_exploit exploit} and {#via_payload} modules.
  #
  #   @return [Hash]

  # @!attribute [rw] desc
  #   Description of session.
  #
  #   @return [String]

  # @!attribute [rw] last_seen
  #   The last time the session was checked to see that it was still open.
  #
  #   @return [DateTime]

  # @!attribute [rw] local_id
  #   The ID number of the in-memory session.
  #
  #   @return [Integer]

  # @!attribute [rw] opened_at
  #   When the session was opened on {#host}.
  #
  #   @return [DateTime]

  # @!attribute [rw] port
  #   The remote port on which this session is running on {#host}.
  #
  #   @return [Integer]

  # @!attribute [rw] stype
  #   The type of the session.
  #
  #   @return [String]

  # @!attribute [rw] via_exploit
  #   The {Mdm::Module::Class#full_name full name} of the exploit module that opened this session.
  #
  #   @return [String]

  # @!attribute [rw] via_payload
  #   The {Mdm::Module::Class#full_name full name} if the payload module that's running this session.
  #
  #   @return [String]

  #
  # Callbacks
  #

  before_destroy :stop

  #
  # Scopes
  #

  scope :alive,
        ->{
          where(closed_at: nil)
        }
  scope :dead,
        ->{
          where(
              Mdm::Session.arel_table[:closed_at].not_eq(nil)
          )
        }
  scope :upgradeable,
        ->{
          platforms = Mdm::Platform.arel_table
          windows = Mdm::Platform.where(fully_qualified_name: 'Windows').first

          alive.where(
              Mdm::Session.arel_table[:stype].eq('shell')
          ).joins(
              :platform
          ).where(
              # inlining of is_or_is_descendant_of(windows) logic
              platforms[:left].gteq(windows.left).and(
                  platforms[:left].lt(windows.right)
              )
          )
        }

  #
  # Serializations
  #

  serialize :datastore, ::MetasploitDataModels::Base64Serializer.new

  #
  #
  # Validations
  #
  #

  #
  # Method validations
  #

  validate :module_class_types

  #
  # Attribute validations
  #

  validates :architecture,
            presence: true
  validates :exploit_class,
            presence: true
  validates :payload_class,
            presence: true
  validates :platform,
            presence: true

  #
  # Methods
  #

  # Returns whether the session can be upgraded to a meterpreter session from a shell session on Windows.
  #
  # @return [true] if {#platform} is some version of Windows and {#stype} is `'shell'`.
  # @return [false] otherwise.
  def upgradeable?
    upgradeable = false

    if stype == 'shell' && platform
      windows = Mdm::Platform.where(fully_qualified_name: 'Windows').first

      if platform.is_or_is_descendant_of?(windows)
        upgradeable = true
      end
    end

    upgradeable
  end

  # @deprecated Use {#exploit_class} to get the {Mdm::Module::Class} and then access {Mdm::Module::Class#full_name}.
  #
  # The full name of the exploit class that opened this session.
  #
  # @return [String] an {Mdm::Module::Class#full_name}
  # @todo Remove obsolete Mdm::Session#via_exploit and Mdm::Session#via_payload (MSP-9287)
  def via_exploit
    ActiveSupport::Deprecation.warn(
        "#{self.class}#via_exploit is deprecated.  " \
        "Use #{self.class}#exploit_class to get the Mdm::Module::Class and then access Mdm::Module::Class#full_name."
    )
    super
  end

  # @deprecated Set {#exploit_class} association.
  #
  # Sets the full name of the exploit class that opened this session.
  #
  # @param full_name [String] an {Mdm::Module::Class#full_name}
  # @return [void]
  # @todo Remove obsolete Mdm::Session#via_exploit and Mdm::Session#via_payload (MSP-9287)
  def via_exploit=(full_name)
    ActiveSupport::Deprecation.warn(
        "#{self.class}#via_exploit= is deprecated.  " \
        "Set #{self.class}#via_exploit association instead."
    )
    super
  end

  # @deprecated Use {#payload_class} to get the {Mdm::Module::Class} and then access {Mdm::Module::Class#full_name}.
  #
  # The full name of the payload class that opened this session.
  #
  # @return [String] an {Mdm::Module::Class#full_name}
  # @todo Remove obsolete Mdm::Session#via_payload and Mdm::Session#via_payload (MSP-9287)
  def via_payload
    ActiveSupport::Deprecation.warn(
        "#{self.class}#via_payload is deprecated.  " \
        "Use #{self.class}#payload_class to get the Mdm::Module::Class and then access Mdm::Module::Class#full_name."
    )
    super
  end

  # @deprecated Set {#payload_class} association.
  #
  # Sets the full name of the payload class that opened this session.
  #
  # @param full_name [String] an {Mdm::Module::Class#full_name}
  # @return [void]
  # @todo Remove obsolete Mdm::Session#via_payload and Mdm::Session#via_payload (MSP-9287)
  def via_payload=(full_name)
    ActiveSupport::Deprecation.warn(
        "#{self.class}#via_payload= is deprecated.  " \
        "Set #{self.class}#via_payload association instead."
    )
    super
  end

  private

  # Validates that exploit_class is an exploit and payload_class is a payload
  #
  # @return [void]
  def module_class_types
    ['exploit', 'payload'].each do |module_type|
      attribute = "#{module_type}_class".to_sym
      module_class = send(attribute)

      # presence validator will handle module_class being nil
      if module_class && module_class.module_type != module_type
        errors.add(attribute, :invalid)
        module_class.errors.add(:module_type, "is not #{module_type}")
      end
    end
  end

  # Stops and closes the session.
  #
  # @todo https://www.pivotaltracker.com/story/show/49026497
  # @return [void]
  def stop
    c = Pro::Client.get rescue nil
    # ignore exceptions (XXX - ideally, stopped an already-stopped session wouldn't throw XMLRPCException)
    c.session_stop(self.local_id) rescue nil
  end

  ActiveSupport.run_load_hooks(:mdm_session, self)
end
