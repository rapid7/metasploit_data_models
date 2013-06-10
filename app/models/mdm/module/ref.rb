# External references to the vulnerability exploited by this module.
class Mdm::Module::Ref < ActiveRecord::Base
  self.table_name = 'module_refs'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   The root of the module metadata tree.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  # @!attribute [r] refs
  #   References with the same name attached to {Mdm::Vuln Mdm::Vulns}.
  #
  #   @return [Array<Mdm::Ref>]
	has_many :refs,
					 :class_name => 'Mdm::Ref',
					 :foreign_key => :name,
					 :primary_key => :name

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   Designation for external reference.  May include a prefix for the authority, such as 'CVE-', in which case the
  #   rest of the name is the designation assigned by that authority.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validates :module_instance, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_ref, self)
end
