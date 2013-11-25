# Join model that maps a {Mdm::Module::Instance model} to a supported {Mdm::Module::Architecture architecture}.
class Mdm::Module::Architecture < ActiveRecord::Base
  include Metasploit::Model::Module::Architecture
  include MetasploitDataModels::Batch::Descendant

  self.table_name = 'module_architectures'

  #
  # Associations
  #

  # @!attribute [rw] architecture
  #   {Mdm::Module::Architecture Architecture} supported by {#module_instance}.
  #
  #   @return [Mdm::Architecture]
  belongs_to :architecture, class_name: 'Mdm::Architecture', inverse_of: :module_architectures

  # @!attribute [rw] module_instance
  #
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, class_name: 'Mdm::Module::Instance', inverse_of: :module_architectures

  #
  # Validations
  #

  validates :architecture_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  ActiveSupport.run_load_hooks(:mdm_module_architecture, self)
end
