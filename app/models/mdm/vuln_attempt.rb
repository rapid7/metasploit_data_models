# An attempt to exploit a {#vuln}.
class Mdm::VulnAttempt < ActiveRecord::Base
  include MetasploitDataModels::Attempt

  #
  # Associations
  #

  # @!attribute [rw] loot
  #   Loot gathered from this attempt.
  #
  #   @return [Mdm::Loot] if {#exploited} is `true`.
  #   @return [nil] if {#exploited} is `false`.
  belongs_to :loot, class_name: 'Mdm::Loot', inverse_of: :vuln_attempt

  # @!attribute [rw] module_class
  #   The module class that attempted the exploit.
  #
  #   @return [Mdm::Module::Class, nil]
  belongs_to :module_class, class_name: 'Mdm::Module::Class', inverse_of: :vuln_attempts

  # @!attribute [rw] session
  #   The session opened by this attempt.
  #
  #   @return [Mdm::Session] if {#exploited} is `true`.
  #   @return [nil] if {#exploited} is `false`.
  belongs_to :session, class_name: 'Mdm::Session', inverse_of: :vuln_attempt

  # @!attribute [rw] vuln
  #   The {Mdm::Vuln vulnerability} that this attempt was exploiting.
  #
  #   @return [Mdm::Vuln]
  belongs_to :vuln, class_name: 'Mdm::Vuln', counter_cache: :vuln_attempt_count, inverse_of: :vuln_attempts

  #
  # Attributes
  #

  # @!attribute [rw] attempted_at
  #   When this attempt was made.
  #
  #   @return [DateTime]

  # @!attribute [rw] exploited
  #   Whether this attempt was successful.
  #
  #   @return [true] if {#vuln} was exploited.
  #   @return [false] if {#vuln} was not exploited.

  # @!attribute [rw] fail_detail
  #   Long details about why this attempt failed.
  #
  #   @return [String] if {#exploited} is `false`.
  #   @return [nil] if {#exploited} is `true`.

  # @!attribute [rw] fail_reason
  #   Short reason why this attempt failed.
  #
  #   @return [String] if {#exploited} is `false`.
  #   @return [nil] if {#exploited} is `true`

  # @!attribute [rw] module
  #   {Mdm::Module::Class#full_name Full name of exploit module} that was used in this attempt.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52595655

  # @!attribute [rw] username
  #   The {Mdm::User#username name of the user} that made this attempt.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52595635

  ActiveSupport.run_load_hooks(:mdm_vuln_attempt, self)
end
