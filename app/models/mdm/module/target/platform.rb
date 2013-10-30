# {#platform} supported by {#module_target}.
class Mdm::Module::Target::Platform < ActiveRecord::Base
  include Metasploit::Model::Module::Target::Platform

  #
  # Associations
  #

  # @!attribute [rw] module_target
  #   The module target that supports {#platform}.
  #
  #   @return [Mdm::Module::Target]
  belongs_to :module_target, class_name: 'Mdm::Module::Target'

  # @!attribute [rw] platform
  #   The platform supported by the {#module_target}.
  #
  #   @return [Mdm::Platform]
  belongs_to :platform, class_name: 'Mdm::Platform'

  #
  # Validations
  #

  validates :platform_id,
            uniqueness: {
                scope: :module_target_id
            }
end