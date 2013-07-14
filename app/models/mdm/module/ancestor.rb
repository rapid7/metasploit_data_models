require 'digest/sha1'

# Module metadata that can be derived from a loaded module, which is an ancestor, in the sense of ruby's
# Module#ancestor, or a metasploit module class, Class<Msf::Module>.  Loaded modules will be either a ruby Module
# (for payloads) or a ruby Class (for all non-payloads).
class Mdm::Module::Ancestor < ActiveRecord::Base
  include Metasploit::Model::Derivation
  include Metasploit::Model::Derivation::FullName

  self.table_name = 'module_ancestors'

  #
  # CONSTANTS
  #

  # File extension used for metasploit modules.
  EXTENSION = '.rb'

  # The {#payload_type payload types} that require {#handler_type}.
  HANDLED_TYPES = [
      'single',
      'stager'
  ]

  # Valid values for {#payload_type} if {#payload?} is `true`.
  PAYLOAD_TYPES = [
      'single',
      'stage',
      'stager'
  ]

  # Regexp to keep '\' out of reference names
  REFERENCE_NAME_REGEXP = /\A[a-z][a-z_0-9]*(?:\/[a-z][a-z_0-9]*)*\Z/

  # Regular expression matching a full SHA-1 hex digest.
  SHA1_HEX_DIGEST_REGEXP = /\A[0-9a-z]{40}\Z/

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] parent_path
  #   Path under which this load's {#module_type_directory type directory} and {#reference_path reference name path}
  #   exists.
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
  #   @return [String] if {#handled?} is `true`.
  #   @return [nil] if {#handled?} is `false`.

  # @!attribute [rw] module_type
  #   The type of the module. This would be called #type, but #type is reserved for ActiveRecord's single table
  #   inheritance.
  #
  #   @return [String] key in `Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE`.

  # @!attribute [rw] payload_type
  #   For payload modules, the {PAYLOAD_TYPES type} of payload, either 'single', 'stage', or 'stager'.
  #
  #   @return ['single', 'stage', 'stager'] if {#payload?} is `true`.
  #   @return [nil] if {#payload?} is `false`

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
  # Derivations
  #

  derives :full_name, :validate => true
  derives :payload_type, :validate => true
  derives :real_path, :validate => true

  # Don't validate attributes that require accessing file system to derive value
  derives :real_path_modified_at, :validate => false
  derives :real_path_sha1_hex_digest, :validate => false

  #
  # Mass Assignment Security
  #

  # full_name is NOT accessible since it's derived and must match {#derived_full_name} so there's no reason for a
  # user to set it.
  # handler_type is accessible because it's needed to derive {Mdm::Module::Class#reference_name}.
  attr_accessible :handler_type
  # module_type is accessible because it's needed to derive {#full_name} and {#real_path}.
  attr_accessible :module_type
  # payload_type is NOT accessible since it's derived and must match {#derived_payload_type}.
  # reference_name is accessible because it's needed to derive {#full_name} and {#real_path}.
  attr_accessible :reference_name
  # real_path is NOT accessible since it must match {#derived_real_path}.
  # real_path_modified_at is NOT accessible since it's derived
  # real_path_sha1_hex_digest is NOT accessible since it's derived
  # parent_path_id is NOT accessible since it should be supplied from context

  #
  # Validations
  #

  validates :full_name,
            :uniqueness => true
  validates :handler_type,
            :nil => {
                :unless => :handled?
            },
            :presence => {
                :if => :handled?
            }
  validates :module_type,
            :inclusion => {
                :in => Metasploit::Model::Module::Ancestor::MODULE_TYPES
            }
  validates :parent_path,
            :presence => true
  validates :payload_type,
            :inclusion => {
                :if => :payload?,
                :in => PAYLOAD_TYPES
            },
            :nil => {
                :unless => :payload?
            }
  validates :real_path,
            :uniqueness => true
  validates :real_path_modified_at,
            :presence => true
  validates :real_path_sha1_hex_digest,
            :format => {
                :with => SHA1_HEX_DIGEST_REGEXP
            },
            :uniqueness => true
  validates :reference_name,
            :format => {
                :with => REFERENCE_NAME_REGEXP
            },
            :uniqueness => {
                :scope => :module_type
            }

  #
  # Methods
  #

  # Derives {#payload_type} from {#reference_name}.
  #
  # @return [String]
  # @return [nil] if {#payload_type_directory} is `nil`
  def derived_payload_type
    derived = nil
    directory = payload_type_directory

    if directory
      derived = directory.singularize
    end

    derived
  end

  # Derives {#real_path} by combining {Mdm::Module::Path#real_path parent_path.real_path}, {#module_type_directory}, and
  # {#reference_path} in the same way the module loader does in metasploit-framework.
  #
  # @return [String] the real path to the file holding the ruby Module or ruby Class represented by this
  #   {Mdm::Module::Ancestor}.
  # @return [nil] if {#parent_path} is `nil`.
  # @return [nil] if {Mdm::Module::Path#real_path parent_path.real_path} is `nil`.
  # @return [nil] if {#module_type_directory} is `nil`.
  # @return [nil] if {#reference_name} is `nil`.
  def derived_real_path
    derived_real_path = nil

    if parent_path and parent_path.real_path and module_type_directory and reference_path
      derived_real_path = File.join(
          parent_path.real_path,
          module_type_directory,
          reference_path
      )
    end

    derived_real_path
  end

  # Derives {#real_path_modified_at} by getting the modification time of the file on-disk.
  #
  # @return [Time] modification time of {#real_path} if {#real_path} exists on disk and modification time can be
  #   queried by user.
  # @return [nil] if {#real_path} does not exist or user cannot query the file's modification time.
  def derived_real_path_modified_at
    real_path_string = real_path.to_s

    begin
      mtime = File.mtime(real_path_string)
    rescue Errno::ENOENT
      nil
    else
      mtime.utc
    end
  end

  # Derives {#real_path_sha1_hex_digest} by running the contents of {#real_path} through Digest::SHA1.hexdigest.
  #
  # @return [String] 40 character SHA1 hex digest if {#real_path} can be read.
  # @return [nil] if {#real_path} cannot be read.
  def derived_real_path_sha1_hex_digest
    begin
      sha1 = Digest::SHA1.file(real_path.to_s)
    rescue Errno::ENOENT
      hex_digest = nil
    else
      hex_digest = sha1.hexdigest
    end

    hex_digest
  end

  # Returns whether {#handler_type} is required or must be `nil` for the given payload_type.
  #
  # @param options [Hash{Symbol => String,nil}]
  # @option options [String, nil] module_type (nil) `nil` or an element of
  #   `Metasploit::Model::Module::Ancestor::MODULE_TYPES`.
  # @option options [String, nil] payload_type (nil) `nil` or an element of {PAYLOAD_TYPES}.
  # @return [true] if {#handler_type} must be present.
  # @return [false] if {#handler_type} must be `nil`.
  def self.handled?(options={})
    options.assert_valid_keys(:module_type, :payload_type)

    handled = false
    module_type = options[:module_type]
    payload_type = options[:payload_type]

    if module_type == 'payload' and HANDLED_TYPES.include? payload_type
      handled = true
    end

    handled
  end

  # Returns whether {#handler_type} is required or must be `nil`.
  #
  # @return (see handled?)
  # @see handled?
  def handled?
    self.class.handled?(
        :module_type => module_type,
        :payload_type => payload_type
    )
  end

  # The directory for {#module_type} under {Mdm::Module::Path parent_path.real_path}.
  #
  # @return [String]
  # @see Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE
  def module_type_directory
    Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE[module_type]
  end

  # Return whether this forms part of a payload (either a single, stage, or stager).
  #
  # @return [true] if {#module_type} == 'payload'
  # @return [false] if {#module_type} != 'payload'
  def payload?
    if module_type == 'payload'
      true
    else
      false
    end
  end

  # The directory for {#payload_type} under {#module_type_directory} in {#real_path}.
  #
  # @return [String] first directory in reference_name
  # @return [nil] if {#payload?} is `false`.
  # @return [nil] if {#reference_name} is `nil`.
  def payload_type_directory
    directory = nil

    if payload? and reference_name
      head, _tail = reference_name.split('/', 2)
      directory = head.singularize
    end

    directory
  end

  # The path relative to the {#module_type_directory} under the {Mdm::Module::Path parent_path.real_path}, including the
  # file {EXTENSION extension}.
  #
  # @return [String] {#reference_name} + {EXTENSION}
  # @return [nil] if {#reference_name} is `nil`.
  def reference_path
    path = nil

    if reference_name
      path = "#{reference_name}#{EXTENSION}"
    end

    path
  end

  ActiveSupport.run_load_hooks(:mdm_module_ancestor, self)
end
