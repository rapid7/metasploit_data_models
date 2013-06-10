class Mdm::Module::Target < ActiveRecord::Base
  self.table_name = 'module_targets'

  #
  # Associations
  #

  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Mass Assignment Security
  #

  attr_accessible :index
  attr_accessible :name

  #
  # Validators
  #

  validates :index, :presence => true
  validates :module_instance, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
