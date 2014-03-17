# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Mdm::Module} namespace.
class Mdm::Module::Instance < ActiveRecord::Base
  include Metasploit::Model::Module::Instance
  include MetasploitDataModels::Batch::Root

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
  belongs_to :default_target, class_name: 'Mdm::Module::Target', inverse_of: :module_instance

  # @!attribute [rw] module_architectures
  #   Joins this {Mdm::Module::Instance} to its supported {Mdm::Architecture architectures}.
  #
  #   @return [Array<Mdm::Module::Architecture>]
  has_many :module_architectures,
           class_name: 'Mdm::Module::Architecture',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute [rw] module_authors
  #   Joins this with {#authors} and {#email_addresses} to model the name and email address used for an author entry in
  #   the module metadata.
  #
  #   @return [Array<Mdm::Module::Author>]
  has_many :module_authors,
           class_name: 'Mdm::Module::Author',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute [rw] module_class
  #   Class-derived metadata to go along with the instance-derived metadata in this model.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :module_class, class_name: 'Mdm::Module::Class', inverse_of: :module_instance

  # @!attribute [rw] module_platform
  #   Joins this {Mdm::Module::Instance} to its supported {Mdm::Platform platforms}.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :module_platforms,
           class_name: 'Mdm::Module::Platform',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute [rw] module_references
  #   Joins {#references} to this {Mdm::Module::Instance}.
  #
  #   @return [Array<Mdm::Module::Reference>]
  has_many :module_references,
           class_name: 'Mdm::Module::Reference',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

  # @!attribute [rw] targets
  #   Names of targets with different configurations that can be exploited by this module.
  #
  #   @return [Array<Mdm::Module::Target>]
  has_many :targets,
           class_name: 'Mdm::Module::Target',
           dependent: :destroy,
           foreign_key: :module_instance_id,
           inverse_of: :module_instance

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

  #
  # Scopes
  #

  # @!method self.compatible_privilege_with(module_instance)
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that are unprivileged if `module_instance` {#privileged} is
  #   `false` or all {Mdm::Module::Instance Mdm::Module::Instances} if `module_instance` {#privileged} is `true` because
  #   a privileged payload can only run if the exploit gives it privileged access.
  #
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :compatible_privilege_with,
        ->(module_instance){
          unless module_instance.privileged?
            where(privileged: false)
          end
        }

  # @!method self.encoders_compatible_with(module_instance)
  #   {Mdm::Module::Instance Mdm::Module::Instances} that share at least 1 {Mdm::Architecture} with the given
  #   `module_instance`'s {Mdm::Module::Instance#archtiectures} and have {#module_class}
  #   {Mdm::Module::Class#module_type} of `'encoder'`.
  #
  #   @param module_instance [Mdm::Module::Instance] module instance whose {Mdm::Module::Instance#architectures} need to
  #     have at least 1 {Mdm::Architecture} shared with the returned {Mdm::Module::Instance Mdm::Module::Instances'}
  #     {Mdm::Module::instance#architectures}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :encoders_compatible_with,
        ->(module_instance){
          with_module_type(
              'encoder'
          ).intersecting_architectures_with(
              module_instance
          ).ranked
        }

  # @!method self.intersecting_architecture_abbreviations
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that share at least 1 {Mdm::Architecture#abbreviation} with
  #   the given `architecture_abbreviations`.
  #
  #   @param architecture_abbreviations [Array<String>]
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :intersecting_architecture_abbreviations,
        ->(architecture_abbreviations){
          joins(
              :architectures
          ).where(
              Mdm::Architecture.arel_table[:abbreviation].in(architecture_abbreviations)
          )
        }

  # @!method self.intersecting_platforms_with(architectured)
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that share at least 1 {Mdm::Architecture} with the given
  #   architectured record's `#architectures`.
  #
  #   @param architectured [Mdm::Module::Instance, Mdm::Module::Target, #architectures] target whose `#architectures`
  #     need to have at least 1 {Mdm::Architecture} shared with the returned
  #     {Mdm::Module::Instance Mdm::Module::Instances'} {Mdm::Module::Instance#architectures}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :intersecting_architectures_with,
        ->(architectured){
          intersecting_architecture_abbreviations(
              architectured.architectures.select(:abbreviation).build_arel
          )
        }

  # @!method self.intersecting_platforms(platforms)
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that has at least 1 {Mdm::Platform} from `platforms`.
  #
  #   @param platforms [Enumerable<Mdm::Platform>, #collect] list of {Mdm::Platform Mdm::Platforms} need to themselves
  #     or their descendants shared with the returned {Mdm::Module::Instance Mdm::Module::Instances'}
  #     {Mdm::Module::Instance#platforms}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :intersecting_platforms,
        ->(platforms){
          platforms_arel_table = Mdm::Platform.arel_table
          platforms_left = platforms_arel_table[:left]
          platforms_right = platforms_arel_table[:right]

          platform_intersection_conditions = platforms.collect { |platform|
            platform_left = platform.left
            platform_right = platform.right

            # the payload's platform is an ancestor or equal to the target `platform`
            platforms_left.lteq(platform_left).and(
                platforms_right.gteq(platform_right)
            ).or(
                # the payload's platform is a descendant or equal to the target 'platform``
                platforms_left.gteq(platform_left).and(
                    platforms_right.lteq(platform_right)
                )
            )
          }
          platform_intersection_union = platform_intersection_conditions.reduce(:or)

          joins(
              :platforms
          ).where(
              platform_intersection_union
          )
        }

  # @!method self.intersecting_platform_fully_qualified_names(platform_fully_qualified_names)
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that has at least 1 {Mdm::Platform}
  #   that either has a {Mdm::Platform#fully_qualified_name} from `platform_fully_qualified_names` or that has an
  #   descendant with a {Mdm::Platform#fully_qualified_name} from `platform_fully_qualified_names`.
  #
  #   @param platform_fully_qualified_names [Array<String>] `Array` of {Mdm::Platform#fully_qualified_name}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :intersecting_platform_fully_qualified_names,
        ->(platform_fully_qualified_names){
          intersecting_platforms(
              Mdm::Platform.where(
                  fully_qualified_name: platform_fully_qualified_names
              )
          )
        }

  # @!method self.intersecting_platforms_with(module_target)
  #   List of {Mdm::Module::Instance Mdm::Module::Instances} that share at least 1 {Mdm::Platform} or descendant with
  #   the given `module_target`'s {Mdm::Module::Target#platforms}.
  #
  #   @param module_target [Mdm::Module::Target] target whose {Mdm::Module::Target#platforms} need to have at least 1
  #     {Mdm::Platform} or its descendants shared with the returned {Mdm::Module::Instance Mdm::Module::Instances'}
  #     {Mdm::Module::Instance#platforms}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :intersecting_platforms_with,
        ->(module_target){
          intersecting_platforms(module_target.platforms)
        }

  # @!method self.nops_compatible_with(module_instance)
  #   {Mdm::Module::Instance Mdm::Module::Instances} that share at least 1 {Mdm::Architecture} with the given
  #   `module_instance`'s {Mdm::Module::Instance#archtiectures} and have {#module_class}
  #   {Mdm::Module::Class#module_type} of `'nop'`.
  #
  #   @param module_instance [Mdm::Module::Instance] module instance whose {Mdm::Module::Instance#architectures} need to
  #     have at least 1 {Mdm::Architecture} shared with the returned {Mdm::Module::Instance Mdm::Module::Instances'}
  #     {Mdm::Module::instance#architectures}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :nops_compatible_with,
        ->(module_instance){
          with_module_type(
              'nop'
          ).intersecting_architectures_with(
              module_instance
          ).ranked
        }

  # @!method self.ranked
  #   Orders {Mdm::Module::Instance Mdm::Module::Instances} by their {#module_class} {Mdm::Module::Class#rank}
  #   {Mdm::Module::Rank#number} in descending order so better, more reliable modules are first.
  #
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  #   @see Mdm::Module::Class.ranked
  scope :ranked,
        ->{
          joins(
              module_class: :rank
          ).order(
              Mdm::Module::Rank.arel_table[:number].desc
          )
        }


  # @!method self.with_module_type(module_type)
  #   {Mdm::Module::Instance} that have {#module_class} {Mdm::Module::Class#module_type} of `module_type`.
  #
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :with_module_type,
        ->(module_type){
          joins(
              :module_class
          ).where(
              Mdm::Module::Class.arel_table[:module_type].eq(module_type)
          )
        }

  # @!method self.payloads_compatible_with(module_target)
  #   @note In addition to the compatibility checks down using the module cache: (1) the actual `Msf::Payload`
  #     referenced by the {Mdm::Module::Instance} must be checked that it's `Msf::Payload#size` fits the size
  #     restrictions of the `Msf::Exploit#payload_space`; and (2) the compatibility checks performed by
  #     `Msf::Module#compatible?` all pass.
  #
  #   {Mdm::Module::Instance} that have (1) 'payload' for {Mdm::Module::Instance#module_type}; (2) a least 1
  #   {Mdm::Architecture} shared between the {Mdm::Module::Instance#architectures} and this target's {#architectures};
  #   (3) at least one shared platform or platform descendant between {Mdm::Module::Instance#platforms} and this
  #   target's {#platforms} or their descendants; and, optionally, (4) that are NOT {Mdm::Module::Instance#privileged?}
  #   if and only if {Mdm::Module::Target#module_instance} is NOT {Mdm::Module::Instance#privileged?}.
  #
  #   @param module_target [Mdm::Module::Target] target with {Mdm::Module::Target#architectures} and
  #     {Mdm::Module::Target#platforms} that need to be compatible with the returned payload
  #     {Mdm::Module::Instance Mdm::Module::Instances}.
  #   @return [ActiveRecord::Relation<Mdm::Module::Instance>]
  scope :payloads_compatible_with,
        ->(module_target){
          with_module_type(
              'payload'
          ).compatible_privilege_with(
              module_target.module_instance
          ).intersecting_architectures_with(
              module_target
          ).intersecting_platforms_with(
              module_target
          ).ranked
        }


  #
  # Validations
  #

  validates :default_action_id,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :default_target_id,
            uniqueness: {
                allow_nil: true,
                unless: :batched?
            }
  validates :module_class_id,
            uniqueness: {
                unless: :batched?
            }

  ActiveSupport.run_load_hooks(:mdm_module_instance, self)
end
