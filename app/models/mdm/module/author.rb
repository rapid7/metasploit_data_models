class Mdm::Module::Author < ActiveRecord::Base
  self.table_name = 'module_authors'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'
  
  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :name, :email
  
  # Model Associations
  
  attr_accessible :detail
  
  #
  # Validations
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  Metasploit::Concern.run(self)
end
