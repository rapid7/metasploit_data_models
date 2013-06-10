class Mdm::Module::Platform < ActiveRecord::Base
  self.table_name = 'module_platforms'

  #
  # Associations
  #

  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validates :module_instance, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_platform, self)
end
