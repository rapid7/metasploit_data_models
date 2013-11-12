# {#platform} supported by {#module_target}.
class Mdm::Module::Target::Platform < ActiveRecord::Base
  include Metasploit::Model::Module::Target::Platform
  include MetasploitDataModels::Batch::Descendant

  #
  # Associations
  #

  # @!attribute [rw] module_target
  #   The module target that supports {#platform}.
  #
  #   @return [Mdm::Module::Target]
  belongs_to :module_target, class_name: 'Mdm::Module::Target', inverse_of: :target_platforms

  # @!attribute [rw] platform
  #   The platform supported by the {#module_target}.
  #
  #   @return [Mdm::Platform]
  belongs_to :platform, class_name: 'Mdm::Platform', inverse_of: :target_platforms

  #
  # Validations
  #

  validates :platform_id,
            uniqueness: {
                scope: :module_target_id,
                unless: :batched?
            }
end