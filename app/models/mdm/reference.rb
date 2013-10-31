# Reference to a {#url} or a {#designation} maintained by an {#authority}, such as CVE, that describes an exposure or
# vulnerability on a {#hosts host} or that is exploited by a {#module_instances module}.
class Mdm::Reference < ActiveRecord::Base
  include Metasploit::Model::Reference

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] authority
  #   The {Mdm::Authority authority} that assigned {#designation}.
  #
  #   @return [Mdm::Authority, nil]
  belongs_to :authority, class_name: 'Mdm::Authority', inverse_of: :references

  # @!attribute [rw] module_references
  #   Joins this {Mdm::Reference} to {#module_instances}.
  #
  #   @return [Array<Mdm::Module::References>]
  has_many :module_references, class_name: 'Mdm::Module::Reference', dependent: :destroy, inverse_of: :reference

  # @!attribute [rw] vuln_references
  #   Joins this {Mdm::Reference} to {#vulns}.
  #
  #   @return [Array<Mdm::VulnReference>]
  has_many :vuln_references, class_name: 'Mdm::VulnReference', dependent: :destroy, inverse_of: :reference

  #
  # :through => :module_references
  #

  # @!attribute [r] module_instances
  #   {Mdm::Module::Instance Modules} that exploit this reference or describe a proof-of-concept (PoC) code that the
  #   module is based on.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances, :class_name => 'Mdm::Module::Instance', :through => :module_references

  #
  # :through => :vuln_references
  #

  # @!attribute [r] vulns
  #   {Mdm::Vuln Vulnerabilities} that are referenced by this.
  #
  #   @return [Array<Mdm::Vuln>]
  has_many :vulns, :class_name => 'Mdm::Vuln', :through => :vuln_references

  #
  # :through => :vulns
  #

  # @!attribute [r] hosts
  #   {Mdm::Host Hosts} that have {#vulns vulnerabilities} references by this {Mdm::Reference}.
  #
  #   @return [Array<Mdm::Host>]
  has_many :hosts, :class_name => 'Mdm::Host', :through => :vulns

  # @!attribute [r] services
  #   {Mdm::Service Services} that have {#vulns vulnerabilities} references by this {Mdm::Reference}.
  #
  #   @return [Array<Mdm::Service>]
  has_many :services, :class_name => 'Mdm::Service', :through => :vulns

  #
  # Attributes
  #

  # @!attribute [rw] designation
  #   A designation (usually a string of numbers and dashes) assigned by {#authority}.
  #
  #   @return [String, nil]

  # @!attribute [rw] url
  #   URL to web page with information about referenced exploit.
  #
  #   @return [String, nil]
end