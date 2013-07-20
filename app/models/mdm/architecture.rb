# The architecture of a {Mdm::Host host's cpu} or that is targeted by the shellcode for a
# {Mdm::Module::Instance module}.
class Mdm::Architecture < ActiveRecord::Base
  include Metasploit::Model::Architecture

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] hosts
  #   Hosts with this architecture.
  #
  #   @return [Array<Mdm::Host>]
  has_many :hosts,
           :class_name => 'Mdm::Host',
           # Mdm::Hosts are have architecture_id nullified instead of being destroyed because Mdm::Host allows a nil
           # Mdm::Host#architecture.
           :dependent => :nullify

  # @!attribute [rw] module_architectures
  #   Join models between this {Mdm::Module::Architecture} and {Mdm::Module::Instance}.
  #
  #   @return [Array<Mdm::Module::Architecture>]
  has_many :module_architectures,
           :class_name => 'Mdm::Module::Architecture',
           :dependent => :destroy

  #
  # :through => :module_architectures
  #

  # @!attribute [r] module_instances
  #   {Mdm::Module::Instance Modules} that have this {Mdm::Module::Architecture} as a
  #   {Mdm::Module::Instance#architectures support architecture}.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances,
           :class_name => 'Mdm::Module::Instance',
           :through => :module_architectures

  #
  # Attributes
  #

  # @!attribute [rw] abbreviation
  #   Abbreviation used for the architecture.  Will match ARCH constants in metasploit-framework.
  #
  #   @return [String]

  # @!attribute [rw] bits
  #   Number of bits supported by this architecture.
  #
  #   @return [32] if 32-bit
  #   @return [64] if 64-bit
  #   @return [nil] if bits aren't applicable, such as for non-CPU architectures like ruby, etc.

  # @!attribute [rw] endianness
  #   The endianness of the architecture.
  #
  #   @return ['big'] if big endian
  #   @return ['little'] if little endian
  #   @return [nil] if endianness is not applicable, such as for software architectures like tty.

  # @!attribute [rw] family
  #   The CPU architecture family.
  #
  #   @return [String] if a CPU architecture.
  #   @return [nil] if not a CPU architecture.

  # @!attribute [rw] summary
  #   Sentence length summary of architecture.  Usually an expansion of the abbreviation or initialism in the
  #   {#abbreviation} and the {#bits} and {#endianness} in prose.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :abbreviation,
            :uniqueness => true
  validates :summary,
            :uniqueness => true

  ActiveSupport.run_load_hooks(:mdm_architecture, self)
end