class Mdm::Module::Mixin < ActiveRecord::Base
  self.table_name = 'module_mixins'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validation
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_mixin, self)
end
