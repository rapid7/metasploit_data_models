class Mdm::ModuleMixin < ActiveRecord::Base
  self.table_name = 'module_mixins'

  #
  # Associations
  #

  belongs_to :module_detail, :class_name => 'Mdm::ModuleDetail'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validation
  #

  validate :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_mixin, self)
end
