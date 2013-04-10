class Mdm::ModuleTarget < ActiveRecord::Base
  self.table_name = 'module_targets'

  #
  # Associations
  #

  belongs_to :module_detail

  #
  # Mass Assignment Security
  #

  attr_accessible :index
  attr_accessible :name

  #
  # Validators
  #

  validate :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
