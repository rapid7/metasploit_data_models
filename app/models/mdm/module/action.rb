class Mdm::Module::Action < ActiveRecord::Base
  self.table_name = 'module_actions'  

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Mass Assignment Security
  #
  
  # Database Columns
  
  attr_accessible :name
  
  # Model Associations
  
  attr_accessible :detail

  #
  # Validations
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  Metasploit::Concern.run(self)
end
