class Mdm::Module::Arch < ActiveRecord::Base
  self.table_name = 'module_archs'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_arch, self)
end
