# Join model between {Mdm::Module::Instance modules} and {Mdm::Reference references} that refer to the exploit in the
# modules.
class Mdm::Module::Reference < ActiveRecord::Base
  include Metasploit::Model::Module::Reference
  include MetasploitDataModels::Batch::Descendant

  self.table_name = 'module_references'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   {Mdm::Module::Instance Module} with {#reference}.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, class_name: 'Mdm::Module::Instance', inverse_of: :module_references

  # @!attribute [rw] reference
  #   {Mdm::Reference reference} to exploit or proof-of-concept (PoC) code for {#module_instance}.
  #
  #   @return [Mdm::Reference]
  belongs_to :reference, class_name: 'Mdm::Reference', inverse_of: :module_references

  #
  # Validations
  #

  validates :reference_id,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }
end