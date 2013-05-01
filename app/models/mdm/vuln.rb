# A vulnerability found on a {#host} or {#service}.
class Mdm::Vuln < ActiveRecord::Base
  #
  # Callbacks
  #

  after_update :save_refs

  #
  # Relations
  #

  # @!attribute [rw] host
  #   The host with this vulnerability.
  #
  #   @return [Mdm::Host]
  belongs_to :host, :class_name => 'Mdm::Host', :counter_cache => :vuln_count

  # @!attribute [rw] service
  #   The service with the vulnerability.
  #
  #   @return [Mdm::Service]
  belongs_to :service, :class_name => 'Mdm::Service', :foreign_key => :service_id

  # @!attribute [rw] vuln_attempts
  #   Attempts to exploit this vulnerability.
  #
  #   @return [Array<Mdm::VulnAttempt>]
  has_many :vuln_attempts,  :dependent => :destroy, :class_name => 'Mdm::VulnAttempt'

  # @!attribute [rw] vuln_details
  #   Additional information about this vulnerability.
  #
  #   @return [Array<Mdm::VulnDetail>]
  has_many :vuln_details,  :dependent => :destroy, :class_name => 'Mdm::VulnDetail'

  # @!attribute [rw] vulns_refs
  #   Join model that joins this vuln to its {Mdm::Ref external references}.
  #
  #   @todo https://www.pivotaltracker.com/story/show/49004623
  #   @return [Array<Mdm::VulnRef>]
  has_many :vulns_refs, :class_name => 'Mdm::VulnRef'

  #
  # Through :vuln_refs
  #

  # @!attribute [rw] refs
  #   External references to this vulnerability.
  #
  #   @return [Array<Mdm::Ref>]
  has_many :refs, :through => :vulns_refs, :class_name => 'Mdm::Ref'

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

  scope :search, lambda { |*args|
    where(
        [
            '(vulns.name ILIKE ? or vulns.info ILIKE ? or refs.name ILIKE ?)',
            "%#{args[0]}%",
            "%#{args[0]}%",
            "%#{args[0]}%"
        ]
    ).joins(
        'LEFT OUTER JOIN vulns_refs ON vulns_refs.vuln_id=vulns.id LEFT OUTER JOIN refs ON refs.id=vulns_refs.ref_id'
    )
  }

  #
  # Validations
  #

  validates :name, :presence => true
  validates_associated :refs

  private

  def before_destroy
    Mdm::VulnRef.delete_all('vuln_id = ?', self.id)
    Mdm::VulnDetail.delete_all('vuln_id = ?', self.id)
    Mdm::VulnAttempt.delete_all('vuln_id = ?', self.id)
  end

  def save_refs
    refs.each { |ref| ref.save(:validate => false) }
  end

  ActiveSupport.run_load_hooks(:mdm_vuln, self)
end
