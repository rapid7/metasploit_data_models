class Mdm::VulnAttempt < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :attempted_at, :exploited, :fail_reason, :username, 
                  :module, :fail_detail
  
  #
  # Associations
  #

  # @!attribute loot
  #   Loot gathered from this attempt.
  #
  #   @return [Mdm::Loot] if {#exploited} is `true`.
  #   @return [nil] if {#exploited} is `false`.
  belongs_to :loot,
             class_name: 'Mdm::Loot',
             inverse_of: :vuln_attempt

  # @!attribute session
  #   The session opened by this attempt.
  #
  #   @return [Mdm::Session] if {#exploited} is `true`.
  #   @return [nil] if {#exploited} is `false`.
  belongs_to :session,
             class_name: 'Mdm::Session',
             inverse_of: :vuln_attempt

  # @!attribute vuln
  #   The {Mdm::Vuln vulnerability} that this attempt was exploiting.
  #
  #   @return [Mdm::Vuln]
  belongs_to :vuln,
             class_name: 'Mdm::Vuln',
             counter_cache: :vuln_attempt_count,
             inverse_of: :vuln_attempts

  #
  # Attributes
  #

  # @!attribute [rw] exploited
  #   Whether this attempt was successful.
  #
  #   @return [true] if {#vuln} was exploited.
  #   @return [false] if {#vuln} was not exploited.

  #
  # Validations
  #

  validates :vuln_id, :presence => true

  Metasploit::Concern.run(self)
end
