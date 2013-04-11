class Mdm::ModuleAuthor < ActiveRecord::Base
  self.table_name = 'module_authors'

  #
  # Associations
  #

  belongs_to :module_detail, :class_name => 'Mdm::ModuleDetail'

  #
  # Mass Assignment Security
  #

  attr_accessible :email
  attr_accessible :name

  #
  # Validations
  #

  validates :module_detail, :presence => true
  validates :name, :presence => true

  ActiveSupport.run_load_hooks(:mdm_module_author, self)
end
