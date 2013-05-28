# Details about an Msf::Module.  Metadata that can be an array is stored in associations in modules under the
# {Mdm::Module} namespace.
class Mdm::Module::Detail < ActiveRecord::Base
  self.table_name = 'module_details'

  #
  # CONSTANTS
  #

  # The directory for a given {#mtype} is a not always the pluralization of {#mtype}, so this maps the {#mtype} to the
  # type directory that is used to generate the {#file} from the {#mtype} and {#refname}.
  DIRECTORY_BY_TYPE = {
      'auxiliary' => 'auxiliary',
      'encoder' => 'encoders',
      'exploit' => 'exploits',
      'nop' => 'nops',
      'payload' => 'payloads',
      'post' => 'post'
  }

  # {#privileged} is Boolean so, valid values are just `true` and `false`, but since both the validation and
  # factory need an array of valid values, this constant exists.
  PRIVILEGES = [
      false,
      true
  ]

  # Converts {#rank}, which is an Integer, to the name used for that rank.
  RANK_BY_NAME = {
      'Manual' => 0,
      'Low' => 100,
      'Average' => 200,
      'Normal' => 300,
      'Good' => 400,
      'Great' => 500,
      'Excellent' => 600
  }

  # Valid values for {#stance}.
  STANCES = [
      'aggressive',
      'passive'
  ]

  #
  # Associations
  #

  # @!attribute [rw] actions
  #   Auxiliary actions to perform when this running this module.
  #
  #   @return [Array<Mdm::Module::Action>]
  has_many :actions,   :class_name => 'Mdm::Module::Action',   :dependent => :destroy

  # @!attribute [rw] archs
  #   Architectures supported by this module.
  #
  #   @return [Array<Mdm::Module::Arch>]
  has_many :archs,     :class_name => 'Mdm::Module::Arch',     :dependent => :destroy

  # @!attribute [rw] authors
  #   Authors (and their emails) of this module.  Usually includes the original discoverer who wrote the
  #   proof-of-concept and then the people that ported the proof-of-concept to metasploit-framework.
  #
  #   @return [Array<Mdm::Module::Mixin>]
  has_many :authors,   :class_name => 'Mdm::Module::Author',   :dependent => :destroy

  # @!attribute [rw] mixins
  #   Mixins used by this module.
  #
  #   @return [Array<Mdm::Module::Mixin>]
  has_many :mixins,    :class_name => 'Mdm::Module::Mixin',    :dependent => :destroy

  # @!attribute [rw] parent_path
  #   Path under which this modules's type directory and reference name paths exist.
  #
  #   @return [Mdm::Module::Path]
  belongs_to :parent_path, :class_name => 'Mdm::Module::Path'

  # @!attribute [rw] platforms
  #   Platforms supported by this module.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :platforms, :class_name => 'Mdm::Module::Platform', :dependent => :destroy

  # @!attribute [rw] refs
  #   External references to the vulnerabilities this module exploits.
  #
  #   @return [Array<Mdm::Module::Ref>]
  has_many :refs,      :class_name => 'Mdm::Module::Ref',      :dependent => :destroy

  # @!attribute [rw] targets
  #   Names of targets with different configurations that can be exploited by this module.
  #
  #   @return [Array<Mdm::Module::Target>]
  has_many :targets,   :class_name => 'Mdm::Module::Target',   :dependent => :destroy

  #
  # Attributes
  #

  # @!attribute [rw] default_action
  #   Name of the default action in {#actions}.
  #
  #   @return [String] {Mdm::Module::Action#name}.

  # @!attribute [rw] default_target
  #   Name of the default target in {#targets}.
  #
  #   @return [String] {Mdm::Module::Target#name}.

  # @!attribute [rw] description
  #   A long, paragraph description of what the module does.
  #
  #   @return [String]

  # @!attribute [rw] disclosure_date
  #   The date the vulnerability exploited by this module was disclosed to the public.
  #
  #   @return [DateTime]

  # @!attribute [rw] file
  #   The full path to the module file on-disk.
  #
  #   @return [String]

  # @!attribute [rw] fullname
  #   The full name of the module.  The full name is "{#mtype}/{#refname}".
  #
  #   @return [String]

  # @!attribute [rw] license
  #   The name of the software license for the module's code.
  #
  #   @return [String]

  # @!attribute [rw] mtime
  #   The modification time of the module file on-disk.
  #
  #   @return [DateTime]

  # @!attribute [rw] mtype
  #   The type of the module.
  #
  #   @return [String] key in {DIRECTORY_BY_TYPE}

  # @!attribute [rw] name
  #   The human readable name of the module.  It is unrelated to {#fullname} or {#refname} and is better thought of
  #   as a short summary of the {#description}.
  #
  #   @return [String]

  # @!attribute [rw] privileged
  #   Whether this module requires priveleged access to run.
  #
  #   @return [Boolean]

  # @!attribute [rw] rank
  #   The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
  #   Bigger values is better.
  #
  #   @return [Integer]

  # @!attribute [rw] ready
  #   Boolean indicating whether the metadata for the module has been updated from the on-disk module.
  #
  #   @return [false] if the associations are still being updated.
  #   @return [true] if this detail and its associations are up-to-date.

  # @!attribute [rw] refname
  #   The reference name of the module.
  #
  #   @return [String]

  # @!attribute [rw] stance
  #   Whether the module is active or passive.  `nil` if the {#mtype module type} does not
  #   {#supports_stance? support stances}.
  #
  #   @return ['active', 'passive', nil]

  #
  # Validations
  #

  validates :mtype,
            :inclusion => {
                :in => DIRECTORY_BY_TYPE.keys
            }
  validates :privileged,
            :inclusion => {
                :in => PRIVILEGES
            }
  validates :rank,
            :inclusion => {
                :in => RANK_BY_NAME.values
            },
            :numericality => {
                :only_integer => true
            }
  validates :refname, :presence => true
  validates :stance,
            :inclusion => {
                :if => :supports_stance?,
                :in => STANCES
            }

  validates_associated :actions
  validates_associated :archs
  validates_associated :authors
  validates_associated :mixins
  validates_associated :platforms
  validates_associated :refs
  validates_associated :targets

  # Returns whether this module supports a {#stance}.  Only modules with {#mtype} `'auxiliary'` and `'exploit'` support
  # a non-nil {#stance}.
  #
  # @return [true] if {#mtype} is `'auxiliary'` or `'exploit'`
  # @return [false] otherwise
  # @see https://github.com/rapid7/metasploit-framework/blob/a6070f8584ad9e48918b18c7e765d85f549cb7fd/lib/msf/core/db_manager.rb#L423
  # @see https://github.com/rapid7/metasploit-framework/blob/a6070f8584ad9e48918b18c7e765d85f549cb7fd/lib/msf/core/db_manager.rb#L436
  def supports_stance?
    supports_stance = false

    if ['auxiliary', 'exploit'].include? mtype
      supports_stance = true
    end

    supports_stance
  end

  ActiveSupport.run_load_hooks(:mdm_module_detail, self)
end
