# Joins {Mdm::Author} and {Mdm::EmailAddress} to {Mdm::Module::Instance} to record authors and the email they used for
# a given module.
class Mdm::Module::Author < ActiveRecord::Base
  include Metasploit::Model::Module::Author

  self.table_name = 'module_authors'

  #
  # Associations
  #

  # @!attribute [rw] author
  #   Author who wrote the {#module_instance module}.
  #
  #   @return [Mdm::Author]
  belongs_to :author, :class_name => 'Mdm::Author', inverse_of: :module_authors

  # @!attribute [rw] email_address
  #   Email address {#author} used when writing {#module_instance module}.
  #
  #   @return [Mdm::EmailAddress] if {#author} gave an email address.
  #   @return [nil] if {#author} only gave a name.
  belongs_to :email_address, class_name: 'Mdm::EmailAddress', inverse_of: :module_authors

  # @!attribute [rw] module_instance
  #   Module written by {#author}.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, class_name: 'Mdm::Module::Instance', inverse_of: :module_authors

  #
  # Validations
  #

  validates :author_id,
            :uniqueness => {
                :scope => :module_instance_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_author, self)
end
