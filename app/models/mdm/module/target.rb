class Mdm::Module::Target < ActiveRecord::Base
  self.table_name = 'module_targets'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Mass Assignment Security
  #

  attr_accessible :index
  attr_accessible :name

  #
  # Validators
  #

  validates :detail, :presence => true
  validates :index, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
