class Mdm::ModuleTarget < ActiveRecord::Base
  self.table_name = 'module_targets'

  #
  # Associations
  #

  belongs_to :module_detail, :class_name => 'Mdm::ModuleDetail'

  #
  # Mass Assignment Security
  #

  attr_accessible :index
  attr_accessible :name

  #
  # Validators
  #

  validates :index, :presence => true
  validates :module_detail, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
