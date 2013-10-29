class Mdm::Module::Target::Architecture < ActiveRecord::Base
  include Metasploit::Model::Module::Target::Architecture

  #
  # Associations
  #

  # @!attribute [rw] architecture
  #   The architecture supported by the {#module_target}.
  #
  #   @return [Mdm::Architecture]
  belongs_to :architecture, class_name: 'Mdm::Architecture'

  # @!attribute [rw] module_target
  #   The module target that supports {#architecture}.
  #
  #   @return [Mdm::Module::Target]
  belongs_to :module_target, class_name: 'Mdm::Module::Target'

  #
  # Validations
  #

  validates :architecture_id,
            uniqueness: {
                scope: :module_target_id
            }
end