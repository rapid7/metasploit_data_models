# Author of one of more {#module_instances modules}.  An author can have 0 or more {#email_addresses} representing that
# the author's email may have changed over the history of metasploit-framework or they are submitting from a work and
# personal email for different code.
class Mdm::Author < ActiveRecord::Base
  include Metasploit::Model::Author

  #
  # Associations
  #

  # @!attribute [rw] module_authors
  #   Joins this to {#email_addresses} and {#module_instances}.
  #
  #   @return [Array<Mdm::Module::Author>]
  has_many :module_authors, :class_name => 'Mdm::Module::Author', :dependent => :destroy, inverse_of: :author

  #
  # :through => :module_authors
  #

  # @!attribute [r] email_addresses
  #   Email addresses used by this author across all {#module_instances}.
  #
  #   @return [Array<Mdm::EmailAddress>]
  has_many :email_addresses, :class_name => 'Mdm::EmailAddress', :through => :module_authors

  # @!attribute [r] module_instances
  #   Modules written by this author.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances, :class_name => 'Mdm::Module::Instance', :through => :module_authors

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   Full name (First + Last name) or handle of author.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :name, :uniqueness => true

  ActiveSupport.run_load_hooks(:mdm_author, self)
end