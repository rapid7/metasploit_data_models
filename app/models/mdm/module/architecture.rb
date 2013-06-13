# Join model that maps a {Mdm::Module::Instance model} to a supported {Mdm::Module::Architecture architecture}.
class Mdm::Module::Architecture < ActiveRecord::Base
  self.table_name = 'module_architectures'

  #
  # Associations
  #

  # @!attribute [rw] architecture
  #   {Mdm::Module::Architecture Architecture} supported by {#module_instance}.
  #
  #   @return [Mdm::Architecture]
  belongs_to :architecture, :class_name => 'Mdm::Architecture'

  # @!attribute [rw] module_instance
  #
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Validations
  #

  validates :architecture,
            :presence => true
  validates :architecture_id,
            :uniqueness => {
                :scope => :module_instance_id
            }
  validates :module_instance,
            :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_architecture, self)
end
