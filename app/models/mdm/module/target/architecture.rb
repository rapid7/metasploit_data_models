# {#architecture} supported by {#module_target}.
class Mdm::Module::Target::Architecture < ActiveRecord::Base
  include Metasploit::Model::Module::Target::Architecture
  include MetasploitDataModels::Batch::Descendant

  #
  # Associations
  #

  # @!attribute [rw] architecture
  #   The architecture supported by the {#module_target}.
  #
  #   @return [Mdm::Architecture]
  belongs_to :architecture, class_name: 'Mdm::Architecture', inverse_of: :target_architectures

  # @!attribute [rw] module_target
  #   The module target that supports {#architecture}.
  #
  #   @return [Mdm::Module::Target]
  belongs_to :module_target, class_name: 'Mdm::Module::Target', inverse_of: :target_architectures

  #
  # Validations
  #

  validates :architecture_id,
            uniqueness: {
                scope: :module_target_id,
                unless: :batched?
            }
end