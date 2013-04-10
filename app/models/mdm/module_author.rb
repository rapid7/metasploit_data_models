class Mdm::ModuleAuthor < ActiveRecord::Base
  self.table_name = 'module_authors'

  #
  # Associations
  #

  belongs_to :module_detail

  #
  # Mass Assignment Security
  #

  attr_accessible :email
  attr_accessible :name

  #
  # Validations
  #

  validate :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_author, self)
end
