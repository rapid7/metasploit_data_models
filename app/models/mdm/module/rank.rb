# The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
# Bigger {#number values} are better.
class Mdm::Module::Rank < ActiveRecord::Base
  include Metasploit::Model::Module::Rank

  self.table_name = 'module_ranks'

  #
  # Associations
  #

  # @!attribute [rw] module_classes
  #   {Mdm::Module::Class Module classes} assigned this rank.
  #
  #   @return [Array<Mdm::Module::Class>]
  has_many :module_classes, class_name: 'Mdm::Module::Class', dependent: :destroy, inverse_of: :rank

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of the rank.
  #
  #   @return [String]

  # @!attribute [rw] number
  #   The numerical value of the rank.  Higher numbers are better.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :name,
            :uniqueness => true
  validates :number,
            :uniqueness => true

  ActiveSupport.run_load_hooks(:mdm_module_rank, self)
end