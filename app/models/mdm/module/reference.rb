# Join model between {Mdm::Module::Instance modules} and {Mdm::References references} that refer to the exploit in the
# modules.
class Mdm::Module::Reference < ActiveRecord::Base
  self.table_name = 'module_references'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   {Mdm::Module::Instance Module} with {#reference}.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  # @!attribute [rw] reference
  #   {Mdm::Reference reference} to exploit or proof-of-concept (PoC) code for {#module_instance}.
  #
  #   @return [Mdm::Reference]
  belongs_to :reference, :class_name => 'Mdm::Reference'

  #
  # Validations
  #

  validates :module_instance, :presence => true
  validates :reference, :presence => true
  validates :reference_id,
            :uniqueness => {
                :scope => :module_instance_id
            }
end