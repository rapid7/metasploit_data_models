# {MetasploitDataModels::ModuleRun} holds the record of having launched piece of Metasploit content.
# It has associations to {Mdm::User} for audit purposes, and makes polymorphic associations to things like
# {Mdm::Vuln} and {Mdm::Host} for flexible record keeping about activity attacking either specific vulns or just
# making mischief on specific remote targets w/out the context of a vuln or even a remote IP service.
class MetasploitDataModels::ModuleRun < ActiveRecord::Base
  #
  # Constants
  #

  # Marks the module as having successfully run
  SUCCEED      = 'succeeded'
  # Marks the run as having not run successfully
  FAIL        = 'failed'
  # Marks the module as having had a runtime error
  ERROR       = 'error'
  # {ModuleRun} objects will be validated against these statuses
  VALID_STATUSES = [SUCCEED, FAIL, ERROR]


  #
  # Attributes
  #

  # @!attribute [rw] attempted_at
  #   The date/time when this module was run
  # @return [Datetime]

  # @!attribute [rw] fail_detail
  #   Arbitrary information captured by the module to give in-depth reason for failure
  # @return [String]

  # @!attribute [rw] fail_reason
  #   One of the values of the constants in {Msf::Module::Failure}
  # @return [String]

  # @!attribute [rw] module_name
  #   The Msf::Module#fullname of the module being run
  # @return [String]

  # @!attribute [rw] port
  #   The port that the remote host was attacked on, if any
  # @return [Fixnum]

  # @!attribute [rw] proto
  #   The name of the protocol that the host was attacked on, if any
  # @return [String]

  # @!attribute [rw] session_id
  #   The {Mdm::Session} that this was run with, in the case of a post module. In exploit modules, this field will
  #   remain null.
  # @return [Datetime]

  # @!attribute [rw] status
  #   The result of running the module
  # @return [String]

  # @!attribute [rw] username
  #   The name of the user running this module
  # @return [String]



  #
  # Associations
  #


  # @!attribute [rw] module_detail
  #  A reference to the Metasploit content module in the DB cache
  #
  #  @return [Mdm::Module::Detail]
  belongs_to :module_detail,
             class_name: 'Mdm::Module::Detail',
             inverse_of: :module_runs


  # @!attribute [rw] spawned_session
  #
  #  The session created by running this module.
  #  Note that this is NOT the session that modules are run on.
  #
  #  @return [Mdm::Session]
  has_one :spawned_session,
             class_name: 'Mdm::Session',
             inverse_of: :originating_module_run


  # @!attribute [rw] target_session
  #
  #  The session this module was run on, if any.
  #  Note that this is NOT a session created by this module run
  #  of exploit modules.
  #
  #  @return [Mdm::Session]
  belongs_to :target_session,
             class_name: 'Mdm::Session',
             foreign_key: :session_id,
             inverse_of: :target_module_runs



  # Declares this model to implement a polymorphic relationship with other models.
  belongs_to :trackable, polymorphic: true


  # @!attribute [rw] user
  #
  #  The user that launched this module
  #
  #  @return [Mdm::User]
  belongs_to :user,
             class_name:  'Mdm::User',
             foreign_key: 'user_id',
             inverse_of: :module_runs



  #
  # Validations
  #

  validates :attempted_at,
            presence: true

  validate :module_information_is_present

  validates :status,
            inclusion: VALID_STATUSES


  private

  # Mark the object as invalid if there is no associated #module_name or {Mdm::ModuleDetail}
  # @return [void]
  def module_information_is_present
    if module_name.blank? && module_detail.blank?
      errors.add(:base, "One of module_name or module_detail_id must be set")
    end
  end

end
