# Actions that auxiliary modules can perform.  Actions are used to select subcommand-like behavior implemented by the
# same auxiliary module.  The semantics of a given action are specific to a given {Mdm::Module::Instance module}: if two
# {Mdm::Module::Instance modules} have {Mdm::Module::Action actions} with the same {Mdm::Module::Action name}, no
# similarity should be assumed between those two {Mdm::Module::Action actions} or {Mdm::Module::Instance modules}.
class Mdm::Module::Action < ActiveRecord::Base
  include Metasploit::Model::Module::Action

  self.table_name = 'module_actions'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   Module that has this action.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, class_name: 'Mdm::Module::Instance', inverse_of: :actions

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of this action.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :name,
            :uniqueness => {
                :scope => :module_instance_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_action, self)
end
