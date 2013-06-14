# An authority that supplies {Mdm::Reference references}, such as CVE.
class Mdm::Authority < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # @!attribute [rw] references
  #   {Mdm::Reference References} that use this authority's scheme for either {Mdm::Reference#designation}.
  #
  #   @return [Array<Mdm::Reference>]
  has_many :references, :class_name => 'Mdm::Reference', :dependent => :destroy

  #
  # :through => :references
  #

  # @!attribute [r] module_references
  #   Joins {#references} to {#module_instances}.
  #
  #   @return [Array<Mdm::Module::References>]
  has_many :module_references, :class_name => 'Mdm::Module::Reference', :through => :references

  # @!attribute [r] vuln_references
  #   Joins {#references} to {#vulns}
  #
  #   @return [Array<Mdm::VulnReference>]
  has_many :vuln_references, :class_name => 'Mdm::VulnReference', :through => :references

  #
  # :through => :module_references
  #

  # @!attribute [r] module_instances
  #   {Mdm::Module::Instance Modules} that have a reference with this authority.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances, :class_name => 'Mdm::Module::Instance', :through => :module_references

  #
  # :through => :vuln_references
  #

  # @!attirbute [r] vulns
  #   Vulnerabilities that have a reference under this authority.
  #
  #   @return [Array<Mdm::Vuln>]
  has_many :vulns, :class_name => 'Mdm::Vuln', :through => :vuln_references

  #
  # Attributes
  #

  # @!attribute [rw] abbreviation
  #   Abbreviation or initialism for authority, such as CVE for 'Common Vulnerability and Exposures'.
  #
  #   @return [String]

  # @!atrribute [rw] summary
  #   An expansion of the {#abbreviation}.
  #
  #   @return [String, nil]

  # @!attribute [rw] url
  #   URL to the authority's home page or root URL for their {#references} database.
  #
  #   @return [String, nil]

  #
  # Mass Assignment Security
  #

  attr_accessible :abbreviation
  attr_accessible :obsolete
  attr_accessible :summary
  attr_accessible :url

  #
  # Validations
  #

  validates :abbreviation,
            :presence => true,
            :uniqueness => true
end