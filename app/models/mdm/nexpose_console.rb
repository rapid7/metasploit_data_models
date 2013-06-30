# A connection to Nexpose from Metasploit.
class Mdm::NexposeConsole < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] vuln_details
  #   Details for vulnerabilities supplied by this Nexpose console.
  #
  #   @return [Array<Mdm::VulnDetail>]
  has_many :vuln_details, :class_name => 'Mdm::VulnDetail', :foreign_key => :nx_console_id

  #
  # Attributes
  #

  # @!attribute [rw] address
  #   Address on which Nexpose is running.
  #
  #   @return [String]

  # @!attribute [rw] cert
  #   @todo https://www.pivotaltracker.com/story/show/52415827
  #   @return [String]

  # @!attribute [rw] created_at
  #   When this Nexpose console was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] enabled
  #   Whether metasploit tried to connect to this Nexpose console.
  #
  #   @return [false] is not allowed to connect.
  #   @return [true] is allowed to connect.

  # @!attribute [rw] name
  #   Name of this Nexpose console to differentiate from other Nexpose consoles.
  #
  #   @return [String]

  # @!attribute [rw] owner
  #   {Mdm::User#username Name of user} that setup this console.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52413415

  # @!attribute [rw] password
  #   Password used to authenticate to Nexpose.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52414551

  # @!attribute [rw] port
  #   Port on {#address} that Nexpose is running.
  #
  #   @return [Integer]

  # @!attribute [rw] status
  #   Status of the connection to Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] updated_at
  #   The last time this Nexpose console was updated.
  #
  #   @return [DateTime]

  # @!attribute [rw] username
  #   Username used to authenticate to Nexpose.
  #
  #   @return [String]

  # @!attribute [rw] version
  #   The version of Nexpose.  Used to handle protocol difference in different versions of Nexpose.
  #
  #   @return [String]

  #
  # Serializations
  #

  # @!attribute [rw] cached_sites
  #   List of sites known to Nexpose.
  #
  #   @return [Array<String>] Array of site names.
  serialize :cached_sites, MetasploitDataModels::Base64Serializer.new

  #
  # Validations
  #

  validates :address, :ip_format => true, :presence => true
  validates :name, :presence => true
  validates :password, :presence => true
  validates :port, :numericality => { :only_integer => true }, :inclusion => {:in => 1..65535}
  validates :username, :presence => true

  ActiveSupport.run_load_hooks(:mdm_nexpose_console, self)
end

