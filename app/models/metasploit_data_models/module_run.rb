# Holds the record of having launched piece of Metasploit content.
# Has associations to {Mdm::User} for audit purposes, and makes polymorphic associations to things like
# {Mdm::Vuln} and {Mdm::Host} for flexible record keeping about activity attacking either specific vulns or just
# making mischief on specific remote targets w/out the context of a vuln or even a remote IP service.
class MetasploitDataModels::ModuleRun < ActiveRecord::Base
  #
  # Constants
  #

  # Marks the module as having successfully run
  STATUS_EXPLOITED     = 'exploited'
  # Marks the run as having not run successfully
  STATUS_FAILED        = 'failed'
  # Marks the module as having had a runtime error
  STATUS_ERROR         = 'error'
  # {ModuleRun} objects will be validated against these statuses
  VALID_STATUSES = [STATUS_EXPLOITED, STATUS_FAILED, STATUS_ERROR]


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
  # @return [Datetime]



  #
  # Associations
  #


  belongs_to :trackable, polymorphic: true

  # The user that launched this module
  # @return [Mdm::User]
  belongs_to :user,
             class_name:  "Mdm::User",
             foreign_key: "user_id",
             inverse_of: :module_runs


end
