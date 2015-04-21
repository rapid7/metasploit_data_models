class Mdm::Module::Platform < ActiveRecord::Base
  self.table_name = 'module_platforms'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Validations
  #

  validates :detail, :presence => true
  validates :name, :presence => true

  Metasploit::Concern.run(self)
end
