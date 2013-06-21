# Email address for used by an {Mdm::Author} for {Mdm::Module::Author credit} on a given {Mdm::Module::Instance module}.
class Mdm::EmailAddress < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] module_authors
  #   Credits where {#authors} used this email address for {#module_instances modules}.
  #
  #   @return [Array<Mdm::Module::Author>]
  has_many :module_authors, :class_name => 'Mdm::Module::Author', :dependent => :destroy

  #
  # :through => :module_authors
  #

  # @!attribute [r] authors
  #   Authors that used this email address.
  #
  #   @return [Array<Mdm::Author>]
  has_many :authors, :class_name => 'Mdm::Author', :through => :module_authors

  # @!attribute [r] module_instances
  #   Modules where this email address was used.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances, :class_name => 'Mdm::Module::Instance', :through => :module_authors

  #
  # Attributes
  #

  # @!attribute [rw] domain
  #   The domain part of the email address after the `'@'`.
  #
  #   @return [String]

  # @!attribute [rw] local
  #   The local part of the email address before the `'@'`.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :domain
  attr_accessible :local

  #
  # Validations
  #

  validates :domain, :presence => true
  validates :local,
            :presence => true,
            :uniqueness => {
                :scope => :domain
            }

  ActiveSupport.run_load_hooks(:mdm_email_address, self)
end