require 'digest/sha1'

# Module metadata that can be derived from a loaded module, which is an ancestor, in the sense of ruby's
# Module#ancestor, or a metasploit module class, Class<Msf::Module>.  Loaded modules will be either a ruby Module
# (for payloads) or a ruby Class (for all non-payloads).
class Mdm::Module::Ancestor < ActiveRecord::Base
  include Metasploit::Model::Module::Ancestor

  self.table_name = 'module_ancestors'

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] parent_path
  #   Path under which this load's type directory, `Metasploit::Model::Module::Ancestor#module_type_directory`, and
  #   reference name path, `Metasploit::Model::Module::Ancestor#reference_path` exists.
  #
  #   @return [Mdm::Module::Path]
  belongs_to :parent_path, :class_name => 'Mdm::Module::Path'

  # @!attribute [rw] relationships
  #   Relates this {Mdm::Module::Ancestor} to the {Mdm::Module::Class Mdm::Module::Classes} that
  #   {Mdm::Module::Relationship#descendant descend} from the {Mdm::Module::Ancestor}.
  #
  #   @return [Array<Mdm::Module::Relationship>]
  has_many :relationships, :class_name => 'Mdm::Module::Relationship', :dependent => :destroy

  #
  # :through => :relationships
  #

  # @!attribute [r] descendants
  #   {Mdm::Module::Class Classes} that either subclass the ruby Class in {#real_path} or include the ruby Module in
  #   {#real_path}.
  #
  #   @return [Array<Mdm::Module::Class>]
  has_many :descendants, :class_name => 'Mdm::Module::Class', :through => :relationships

  #
  # Attributes
  #

  # @!attribute [rw] full_name
  #   The full name of the module.  The full name is `"#{module_type}/#{reference_name}"`.
  #
  #   @return [String]

  # @!attribute [rw] handler_type
  #   The handler type (in the case of singles) or (in the case of stagers) the handler type alias.  Handler type is
  #   appended to the end of the single's or stage's {#reference_name} to get the {Mdm::Module::Class#reference_name}.
  #
  #   @return [String] if `Metasploit::Module::Module::Ancestor#handled?` is `true`.
  #   @return [nil] if `Metasploit::Module::Module::Ancestor#handled?` is `false`.

  # @!attribute [rw] module_type
  #   The type of the module. This would be called #type, but #type is reserved for ActiveRecord's single table
  #   inheritance.
  #
  #   @return [String] key in `Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE`.

  # @!attribute [rw] payload_type
  #   For payload modules, the type of payload, either 'single', 'stage', or 'stager'.
  #
  #   @return ['single', 'stage', 'stager'] if `Metasploit::Model::Module::Ancestor#payload?` is `true`.
  #   @return [nil] if `Metasploit::Model::Module::Ancestor#payload?` is `false`
  #   @see Metasploit::Model::Module::Ancestor::PAYLOAD_TYPES

  # @!attribute [rw] real_path
  #   The real (absolute) path to module file on-disk.
  #
  #   @return [String]

  # @!attribute [rw] real_path_modified_at
  #   The modification time of the module {#real_path file on-disk}.
  #
  #   @return [DateTime]

  # @!attribute [rw] real_path_sha1_hex_digest
  #   The SHA1 hexadecimal digest of contents of the file at {#real_path}.  Stored as a string because postgres does not
  #   have support for a 160 bit numerical type and the hexdigest format is more recognizable when using SQL directly.
  #
  #   @see Digest::SHA1#hexdigest
  #   @return [String]

  # @!attribute [rw] reference_name
  #   The reference name of the module.  The name of the module under its {#module_type type}.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  # parent_path_id is NOT accessible since it should be supplied from context

  #
  # Validations
  #

  validates :full_name,
            :uniqueness => true
  validates :real_path,
            :uniqueness => true
  validates :real_path_sha1_hex_digest,
            :uniqueness => true
  validates :reference_name,
            :uniqueness => {
                :scope => :module_type
            }

  ActiveSupport.run_load_hooks(:mdm_module_ancestor, self)
end
