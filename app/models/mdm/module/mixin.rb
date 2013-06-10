class Mdm::Module::Mixin < ActiveRecord::Base
  self.table_name = 'module_mixins'

  #
  # Associations
  #

  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validation
  #

  validates :module_instance, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_mixin, self)
end
