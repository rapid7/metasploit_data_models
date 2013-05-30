# Actions that auxiliary modules can perform.  Actions are used to select subcommand-like behavior implemented by the
# same auxiliary module.
class Mdm::Module::Action < ActiveRecord::Base
  self.table_name = 'module_actions'

  #
  # Associations
  #

  # @!attribute [rw] detail
  #   Module that has this action.
  #
  #   @return [Mdm::Module::Detail]
  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of this action.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_action, self)
end
