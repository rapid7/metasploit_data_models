# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Mdm::Module} namespace.
class Mdm::Module::Instance < ActiveRecord::Base
  include Metasploit::Model::Module::Instance

  self.table_name = 'module_instances'

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] actions
  #   Auxiliary actions to perform when this running this module.
  #
  #   @return [Array<Mdm::Module::Action>]
  has_many :actions,
           class_name: 'Mdm::Module::Action',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute [rw] default_action
  #   The default action in {#actions}.
  #
  #   @return [Mdm::Module::Action]
  belongs_to :default_action, class_name: 'Mdm::Module::Action', inverse_of: :module_instance

  # @!attribute [rw] default_target
  #   The default target in {#targets}.
  #
  #   @return [Mdm::Module::Target]
  belongs_to :default_target, :class_name => 'Mdm::Module::Target'

  # @!attribute [rw] module_architectures
  #   Joins this {Mdm::Module::Instance} to its supported {Mdm::Architecture architectures}.
  #
  #   @return [Array<Mdm::Module::Architecture>]
  has_many :module_architectures,
           :class_name => 'Mdm::Module::Architecture',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] module_authors
  #   Joins this with {#authors} and {#email_addresses} to model the name and email address used for an author entry in
  #   the module metadata.
  #
  #   @return [Array<Mdm::Module::Author>]
  has_many :module_authors,
           :class_name => 'Mdm::Module::Author',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] module_class
  #   Class-derived metadata to go along with the instance-derived metadata in this model.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :module_class, :class_name => 'Mdm::Module::Class'

  # @!attribute [rw] module_platform
  #   Joins this {Mdm::Module::Instance} to its supported {Mdm::Platform platforms}.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :module_platforms,
           :class_name => 'Mdm::Module::Platform',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] module_references
  #   Joins {#references} to this {Mdm::Module::Instance}.
  #
  #   @return [Array<Mdm::Module::Reference>]
  has_many :module_references,
           :class_name => 'Mdm::Module::Reference',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] targets
  #   Names of targets with different configurations that can be exploited by this module.
  #
  #   @return [Array<Mdm::Module::Target>]
  has_many :targets, :class_name => 'Mdm::Module::Target', :dependent => :destroy, :foreign_key => :module_instance_id

  #
  # :through => :module_architectures
  #

  # @!attribute [r] architectures
  #   The {Mdm::Module::Architecture architectures} supported by this module.
  #
  #   @return [Array<Mdm::Architecture>]
  has_many :architectures, :class_name => 'Mdm::Architecture', :through => :module_architectures

  #
  # :through => :module_authors
  #

  # @!attribute [r] authors
  #   The names of the authors of this module.
  #
  #   @return [Array<Mdm::Author>]
  has_many :authors, :class_name => 'Mdm::Author', :through => :module_authors

  # @!attribute [r] email_addresses
  #   The email addresses of the authors of this module.
  #
  #   @return [Array<Mdm::EmailAddress>]
  has_many :email_addresses, :class_name => 'Mdm::EmailAddress', :through => :module_authors, :uniq => true

  #
  # :through => :module_class
  #

  # @!attribute [r] rank
  #   The rank of this module.
  #
  #   @return [Mdm::Module::Rank]
  has_one :rank, :class_name => 'Mdm::Module::Rank', :through => :module_class

  #
  # :through => :module_platforms
  #

  # @!attribute [r] platforms
  #   Platforms supported by this module.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :platforms, :class_name => 'Mdm::Platform', :through => :module_platforms

  #
  # :through => :module_references
  #

  # @!attribute [r] references
  #   External references to the exploit or proof-of-concept (PoC) code in this module.
  #
  #   @return [Array<Mdm::Reference>]
  has_many :references, :class_name => 'Mdm::Reference', :through => :module_references

  #
  # :through => :references
  #

  # @!attribute [r] authorities
  #   Authorities across all {#references} to this module.
  #
  #   @return [Array<Mdm::Authority>]
  has_many :authorities, :class_name => 'Mdm::Authority', :through => :references, :uniq => true

  # @!attribute [r] vuln_references
  #   Joins {#vulns} to {#references}.
  #
  #   @return [Array<Mdm::VulnReference>]
  has_many :vuln_references, :class_name => 'Mdm::VulnReference', :through => :references

  #
  # :through => :vuln_references
  #

  # @!attribute [r] vulns
  #   Vulnerabilities with same {Mdm::Reference reference} as this module.
  #
  #   @return [Array<Mdm::Vuln>]
  has_many :vulns, :class_name => 'Mdm::Vuln', :through => :vuln_references, :uniq => true

  #
  # :through => :vulns
  #

  # @!attribute [r] vulnerable_hosts
  #   Hosts vulnerable to this module.
  #
  #   @return [Array<Mdm::Host>]
  has_many :vulnerable_hosts, :class_name => 'Mdm::Host', :source => :host, :through => :vulns, :uniq => true

  # @!attribute [r] vulnerable_services
  #   Services vulnerable to this module.
  #
  #   @return [Array<Mdm::Service>]
  has_many :vulnerable_services, :class_name => 'Mdm::Service', :source => :service, :through => :vulns, :uniq => true

  #
  # Attributes
  #

  # @!attribute [rw] description
  #   A long, paragraph description of what the module does.
  #
  #   @return [String]

  # @!attribute [rw] disclosed_on
  #   The date the vulnerability exploited by this module was disclosed to the public.
  #
  #   @return [Date, nil]

  # @!attribute [rw] license
  #   The name of the software license for the module's code.
  #
  #   @return [String]

  # @!attribute [rw] name
  #   The human readable name of the module.  It is unrelated to {Mdm::Module::Class#full_name} or
  #   {Mdm::Module::Class#reference_name} and is better thought of as a short summary of the {#description}.
  #
  #   @return [String]

  # @!attribute [rw] privileged
  #   Whether this module requires privileged access to run.
  #
  #   @return [Boolean]

  # @!attribute [rw] stance
  #   Whether the module is active or passive.  `nil` if the {Mdm::Module::Class#module_type module type} does not
  #   support stances.
  #
  #   @return ['active', 'passive', nil]
  #   @see Metasploit::Model::Module::Instance#supports_stance?

  ActiveSupport.run_load_hooks(:mdm_module_instance, self)
end
