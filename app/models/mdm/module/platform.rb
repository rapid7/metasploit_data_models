# Join model between {Mdm::Module::Instance} and {Mdm::Platform} used to represent a platform that a given module
# supports.
class Mdm::Module::Platform < ActiveRecord::Base
  include Metasploit::Model::Module::Platform

  self.table_name = 'module_platforms'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   Module that supports {#platform}.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  # @!attribute [rw] platform
  #  Platform supported by {#module_instance}.
  #
  #  @return [Mdm::Platform]
  belongs_to :platform, :class_name => 'Mdm::Platform'

  #
  # Validations
  #

  validates :platform_id,
            :uniqueness => {
                :scope => :module_instance_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_platform, self)
end
