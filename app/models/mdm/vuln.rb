# A vulnerability found on a {#host} or {#service}.
class Mdm::Vuln < ActiveRecord::Base
  
  #
  # Associations
  #

  # @!attribute exploit_attempts
  #   Attempts to exploit this vulnerability.
  #
  #   @return [ActiveRecord::Relation<Mdm::ExploitAttempt>]
  has_many :exploit_attempts,
           class_name: 'Mdm::ExploitAttempt',
           inverse_of: :vuln

  # @!attribute [rw] host
  #   The host with this vulnerability.
  #
  #   @return [Mdm::Host]
  belongs_to :host,
             class_name: 'Mdm::Host',
             counter_cache: :vuln_count,
             inverse_of: :vulns

  # @!attribute [rw] service
  #   The service with the vulnerability.
  #
  #   @return [Mdm::Service]
  belongs_to :service,
             class_name: 'Mdm::Service',
             inverse_of: :vulns

  # @!attribute [rw] vuln_attempts
  #   Attempts to exploit this vulnerability.
  #
  #   @return [Array<Mdm::VulnAttempt>]
  has_many :vuln_attempts,
           class_name: 'Mdm::VulnAttempt',
           dependent: :destroy,
           inverse_of: :vuln

  # @!attribute [rw] vuln_details
  #   Additional information about this vulnerability.
  #
  #   @return [Array<Mdm::VulnDetail>]
  has_many :vuln_details,
           class_name: 'Mdm::VulnDetail',
           dependent: :destroy,
           inverse_of: :vuln

  # @!attribute [rw] vulns_refs
  #   Join model that joins this vuln to its {Mdm::Ref external references}.
  #
  #   @return [Array<Mdm::VulnRef>]
  has_many :vulns_refs,
           class_name: 'Mdm::VulnRef',
           dependent: :destroy,
           inverse_of: :vuln

  # @!attribute [rw] notes
  #   Notes about the vuln entered by a user with {Mdm::Note#created_at oldest notes} first.
  #
  #   @return [Array<Mdm::Note>]
  has_many :notes,
           -> { order('notes.created_at') },
           class_name: 'Mdm::Note',
           inverse_of: :vuln,
           dependent: :delete_all


  #
  # Through :vuln_refs
  #

  # @!attribute [r] refs
  #   External references to this vulnerability.
  #
  #   @return [Array<Mdm::Ref>]
  has_many :refs, :class_name => 'Mdm::Ref', :through => :vulns_refs

  #
  #  Through refs
  #

  # @!attribute [r] module_refs
  #   References in module that match {Mdm::Ref#name names} in {#refs}.
  #
  #   @return [Array<Mdm::Module::Ref>]
  has_many :module_refs, :class_name => 'Mdm::Module::Ref', :through => :refs

  #
  # Through module_refs
  #

  # @!attribute [r] module_details
  #   {Mdm::Module::Detail Modules} that share the same external references as this vuln.
  #
  #   @return [Array<Mdm::Module::Detail>]
  has_many :module_details,
            -> { uniq },
            :class_name => 'Mdm::Module::Detail',
            :source => :detail,
            :through => :module_refs
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
  # Callbacks
  #

  after_update :save_refs

  #
  # Scopes
  #

  scope :search, lambda { |query|
    formatted_query = "%#{query}%"

    where(
        arel_table[:name].matches(formatted_query).or(
            arel_table[:info].matches(formatted_query)
        ).or(
            Mdm::Ref.arel_table[:name].matches(formatted_query)
        )
    ).includes(
        :refs
    )
  }

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :name, :info, :exploited_at
  
  # Foreign Keys
  
  attr_accessible :host_id, :service_id
  
  # Model Associations
  
  attr_accessible :exploit_attempts, :host, :service, :vuln_attempts,
                  :vuln_details, :vulns_refs, :refs, :module_refs,
                  :module_details

  #
  # Validations
  #

  validates :name, :presence => true
  validates :name, length: {maximum: 255}
  validates_associated :refs

  private

  def save_refs
    refs.each { |ref| ref.save(:validate => false) }
  end

  public

  Metasploit::Concern.run(self)
end
