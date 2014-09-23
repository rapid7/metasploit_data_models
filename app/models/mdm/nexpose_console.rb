class Mdm::NexposeConsole < ActiveRecord::Base
  #
  # Mass Assignment Security
  #

  attr_accessible :enabled, :owner, :address, :port, :username, :password, 
                  :status, :version, :cert, :cached_sites, :name
  
  #
  # Associations
  #

  # @!attribute vuln_details
  #   Details for vulnerabilities supplied by this Nexpose console.
  #
  #   @return [ActiveRecord::Relation<Mdm::VulnDetail>]
  has_many :vuln_details,
           class_name: 'Mdm::VulnDetail',
           foreign_key: :nx_console_id,
           inverse_of: :nexpose_console

  #
  # Serializations
  #

  serialize :cached_sites, MetasploitDataModels::Base64Serializer.new

  #
  # Validations
  #

  validates :address, :presence => true
  validates :name, :presence => true
  validates :password, :presence => true
  validates :port, :numericality => { :only_integer => true }, :inclusion => {:in => 1..65535}
  validates :username, :presence => true

  Metasploit::Concern.run(self)
end

