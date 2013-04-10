class Mdm::ModulePlatform < ActiveRecord::Base
  self.table_name = 'module_platforms'

  #
  # Associations
  #

  belongs_to :module_detail

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validate :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_platform, self)
end
