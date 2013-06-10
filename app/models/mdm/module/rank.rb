# The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
# Bigger {#number values} are better.
class Mdm::Module::Rank < ActiveRecord::Base
  self.table_name = 'module_ranks'

  #
  # CONSTANTS
  #

  # Regular expression to ensure that {#name} is a word starting with a capital letter
  NAME_REGEXP = /\A[A-Z][a-z]+\Z/

  # Converts {#name} to {#number}.  Used for seeding.  Seeds exist so that reports can use module_ranks to get the name
  # of a rank without having to duplicate this constant.
  NUMBER_BY_NAME = {
      'Manual' => 0,
      'Low' => 100,
      'Average' => 200,
      'Normal' => 300,
      'Good' => 400,
      'Great' => 500,
      'Excellent' => 600
  }

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
  # Mass Assignment Security
  #

  attr_accessible :name
  attr_accessible :number

  #
  # Validations
  #

  validates :name,
            # To ensure NUMBER_BY_NAME and seeds stay in sync.
            :inclusion => {
                :in => NUMBER_BY_NAME.keys
            },
            # To ensure new seeds follow pattern.
            :format => {
                :with => NAME_REGEXP
            }
  validates :number,
            # to ensure NUMBER_BY_NAME and seeds stay in sync.
            :inclusion => {
                :in => NUMBER_BY_NAME.values
            },
            # To ensure new seeds follow pattern.
            :numericality => {
                :integer_only => true
            }

  ActiveSupport.run_load_hooks(:mdm_module_rank, self)
end