class Mdm::Module::Target < ActiveRecord::Base
  self.table_name = 'module_targets'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

  #
  # Validators
  #

  validates :detail, :presence => true
  validates :index, :presence => true
  validates :name, :presence => true

  Metasploit::Concern.run(self)
end
