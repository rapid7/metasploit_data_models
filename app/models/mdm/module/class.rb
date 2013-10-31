# 1. A ruby Class defined in one {Mdm::Module::Ancestor#real_path} for non-payloads.
# 2. A ruby Class with one or more ruby Modules mixed into the Class from {Mdm::Module::Ancestor#real_path multiple paths}
#    for payloads.
class Mdm::Module::Class < ActiveRecord::Base
  include Metasploit::Model::Module::Class

  self.table_name = 'module_classes'

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] module_instance
  #   Instance-derived metadata to go along with the class-derived metadata from this model.
  #
  #   @return [Mdm::Module::Instance]
  has_one :module_instance,
          class_name: 'Mdm::Module::Instance',
          dependent: :destroy,
          foreign_key: :module_class_id,
          inverse_of: :module_class

  # @!attribute [rw] rank
  #   The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
  #   Bigger values is better.
  #
  #   @return [Mdm::Module::Rank]
  belongs_to :rank, class_name: 'Mdm::Module::Rank', inverse_of: :module_classes

  # @!attribute [rw] relationships
  #   Join model between {Mdm::Module::Class} and {Mdm::Module::Ancestor} that represents that the Class or Module in
  #   {Mdm::Module::Ancestor#real_path} is an ancestor of the Class represented by this {Mdm::Module::Class}.
  #
  #   @return [Array<Mdm::Module::Relationship>]
  has_many :relationships,
           class_name: 'Mdm::Module::Relationship',
           dependent: :destroy,
           foreign_key: :descendant_id,
           inverse_of: :descendant

  #
  # :through => :relationships
  #

  # @!attribute [r] ancestors
  #   The Class or Modules that were loaded to make this module Class.
  #
  #   @return [Array<Mdm::Module::Ancestor>]
  has_many :ancestors, :class_name => 'Mdm::Module::Ancestor', :through => :relationships

  #
  # Attributes
  #

  # @!attribute [rw] full_name
  #   The full name (type + reference) for the Class<Msf::Module>.  This is merely a denormalized cache of
  #   `"#{{#module_type}}/#{{#reference_name}}"` as full_name is used in numerous queries and reports.
  #
  #   @return [String]

  # @!attribute [rw] module_type
  #   A denormalized cache of the {Mdm::Module::Class#module_type ancestors' module_types}, which must all be the
  #   same.  This cache exists so that queries for modules of a given type don't need include the {#ancestors}.
  #
  #   @return [String]

  # @!attribute [rw] payload_type
  #   For payload modules, the type of payload, either 'single' or 'staged'.
  #
  #   @return [String] if `Metasploit::Model::Module::Class#payload?` is `true`.
  #   @return [nil] if `Metasploit::Model::Module::Class#payload?` is `false`
  #   @see Metasploit::Model::Module::Class::PAYLOAD_TYPES
  #   @see Metasploit::Model::Module::Class::payload?

  # @!attribute [rw] reference_name
  #   The reference name for the Class<Msf::Module>. For non-payloads, this will just be
  #   {Mdm::Module::Ancestor#reference_name} for the only element in {#ancestors}.  For payloads composed of a
  #   stage and stager, the reference name will be derived from the {Mdm::Module::Ancestor#reference_name} of each
  #   element {#ancestors} or an alias defined in those Modules.
  #
  #   @return [String]

  ActiveSupport.run_load_hooks(:mdm_module_class, self)
end