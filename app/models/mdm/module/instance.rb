# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Mdm::Module} namespace.
class Mdm::Module::Instance < ActiveRecord::Base
  self.table_name = 'module_instances'

  #
  # CONSTANTS
  #

  # {#privileged} is Boolean so, valid values are just `true` and `false`, but since both the validation and
  # factory need an array of valid values, this constant exists.
  PRIVILEGES = [
      false,
      true
  ]

  # Valid values for {#stance}.
  STANCES = [
      'aggressive',
      'passive'
  ]

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] actions
  #   Auxiliary actions to perform when this running this module.
  #
  #   @return [Array<Mdm::Module::Action>]
  has_many :actions, :class_name => 'Mdm::Module::Action', :dependent => :destroy, :foreign_key => :module_instance_id

  # @!attribute [rw] authors
  #   Authors (and their emails) of this module.  Usually includes the original discoverer who wrote the
  #   proof-of-concept and then the people that ported the proof-of-concept to metasploit-framework.
  #
  #   @return [Array<Mdm::Module::Mixin>]
  has_many :authors, :class_name => 'Mdm::Module::Author', :dependent => :destroy

  # @!attribute [rw] default_action
  #   The default action in {#actions}.
  #
  #   @return [Mdm::Module::Action]
  belongs_to :default_action, :class_name => 'Mdm::Module::Action'

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

  # @!attribute [rw] module_class
  #   Class-derived metadata to go along with the instance-derived metadata in this model.
  #
  #   @return [Mdm::Module::Class]
  belongs_to :module_class, :class_name => 'Mdm::Module::Class'

  # @!attribute [rw] module_platform
  #   Joins this {Mdm::Module::Instance} to its supported {Mdm::Platforms platforms}.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :module_platforms,
           :class_name => 'Mdm::Module::Platform',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] module_references
  #   Joins {#references} to this {Mdm::Module:Instance}.
  #
  #   @return [Array<Mdm::Module::Refeference>]
  has_many :module_references,
           :class_name => 'Mdm::Module::Reference',
           :dependent => :destroy,
           :foreign_key => :module_instance_id

  # @!attribute [rw] targets
  #   Names of targets with different configurations that can be exploited by this module.
  #
  #   @return [Array<Mdm::Module::Target>]
  has_many :targets, :class_name => 'Mdm::Module::Target', :dependent => :destroy

  #
  # :through => :module_architectures
  #

  # @!attribute [r] architectures
  #   The {Mdm::Module::Architecture architectures} supported by this {Mdm::Module::Architecture}.
  #
  #   @return [Array<Mdm::Architecture>]
  has_many :architectures, :class_name => 'Mdm::Architecture', :through => :module_architectures

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
  #   The human readable name of the module.  It is unrelated to {#fullname} or {#refname} and is better thought of
  #   as a short summary of the {#description}.
  #
  #   @return [String]

  # @!attribute [rw] privileged
  #   Whether this module requires privileged access to run.
  #
  #   @return [Boolean]

  # @!attribute [rw] stance
  #   Whether the module is active or passive.  `nil` if the {#mtype module type} does not
  #   {#supports_stance? support stances}.
  #
  #   @return ['active', 'passive', nil]

  #
  # Validations
  #

  validates :module_class,
            :presence => true
  validates :privileged,
            :inclusion => {
                :in => PRIVILEGES
            }
  validates :stance,
            :inclusion => {
                :if => :supports_stance?,
                :in => STANCES
            }

  # Returns whether this module supports a {#stance}.  Only modules with {#mtype} `'auxiliary'` and `'exploit'` support
  # a non-nil {#stance}.
  #
  # @return [true] if {Mdm::Module::Class#module_type module_class.module_type} is `'auxiliary'` or `'exploit'`
  # @return [false] otherwise
  # @see https://github.com/rapid7/metasploit-framework/blob/a6070f8584ad9e48918b18c7e765d85f549cb7fd/lib/msf/core/db_manager.rb#L423
  # @see https://github.com/rapid7/metasploit-framework/blob/a6070f8584ad9e48918b18c7e765d85f549cb7fd/lib/msf/core/db_manager.rb#L436
  def supports_stance?
    supports_stance = false

    if module_class and ['auxiliary', 'exploit'].include?(module_class.module_type)
      supports_stance = true
    end

    supports_stance
  end

  ActiveSupport.run_load_hooks(:mdm_module_instance, self)
end
