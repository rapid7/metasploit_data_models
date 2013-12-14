# A vulnerability found on a {#host} or {#service}.
class Mdm::Vuln < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] exploit_attempts
  #   Attempts to exploit this vulnerability.
  #
  #   @return [Array<Mdm::ExploitAttempt>]
  has_many :exploit_attempts, class_name: 'Mdm::ExploitAttempt', inverse_of: :vuln

  # @!attribute [rw] host
  #   The host with this vulnerability.
  #
  #   @return [Mdm::Host]
  belongs_to :host, class_name: 'Mdm::Host', counter_cache: :vuln_count, inverse_of: :vulns

  # @!attribute [rw] service
  #   The service with the vulnerability.
  #
  #   @return [Mdm::Service]
  belongs_to :service, class_name: 'Mdm::Service', inverse_of: :vulns

  # @!attribute [rw] vuln_attempts
  #   Attempts to exploit this vulnerability.
  #
  #   @return [Array<Mdm::VulnAttempt>]
  has_many :vuln_attempts, class_name: 'Mdm::VulnAttempt', dependent: :destroy, inverse_of: :vuln

  # @!attribute [rw] vuln_details
  #   Additional information about this vulnerability.
  #
  #   @return [Array<Mdm::VulnDetail>]
  has_many :vuln_details, class_name: 'Mdm::VulnDetail', dependent: :destroy, inverse_of: :vuln

  # @!attribute [rw] vuln_references
  #   Joins this {Mdm::Vuln} to its {#references}.
  #
  #   @return [Array<Mdm::VulnReference>]
  has_many :vuln_references, class_name: 'Mdm::VulnReference', dependent: :destroy, inverse_of: :vuln

  #
  # :through  => :vuln_references
  #

  # @!attribute [r] references
  #   External references to this vulnerability.
  #
  #   @return [Array<Mdm::Referefence>]
  has_many :references, :class_name => 'Mdm::Reference', :through => :vuln_references

  #
  # :through => :references
  #

  # @!attribute [r] module_references
  #   Joins {#references} and {#module_instances}.
  #
  #   @return [Array<Mdm::Module::Reference>]
  has_many :module_references, :class_name => 'Mdm::Module::Reference', :through => :references

  #
  # :through  => module_references
  #

  # @!attribute [r] module_instances
  #   {Mdm::Module::Instance Modules} that share the same external references as this vuln.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances,
           :class_name => 'Mdm::Module::Instance',
           :through => :module_references,
           :uniq => true

  #
  # Attributes
  #

  # @!attribute [rw] exploited_at
  #   When the vulnerability was exploited
  #
  #   @return [DateTime]

  # @!attribute [rw] name
  #   The name of the vulnerability in metasploit-framework or from the import source.
  #
  #   @return [String]

  # @!attribute [rw] info
  #   Additional information about the vulnerability
  #
  #   @return [String]

  # @!attribute [rw] vuln_attempt_count
  #   Counter cache for number of {#vuln_attempts}.
  #
  #   @return [Integer]

  # @!attribute [rw] vuln_detail_count
  #   Counter cache for number of {#vuln_details}.
  #
  #   @return [Integer]

  #
  # Scopes
  #

  scope :search, lambda { |query|
    formatted_query = "%#{query}%"

    where(
        arel_table[:name].matches(formatted_query).or(
            arel_table[:info].matches(formatted_query)
        ).or(
            Mdm::Reference.arel_table[:designation].matches(formatted_query)
        )
    ).includes(
        :references
    )
  }

  #
  # Validations
  #

  validates :name,
            length: {
                maximum: 255
            },
            presence: true

  ActiveSupport.run_load_hooks(:mdm_vuln, self)
end
