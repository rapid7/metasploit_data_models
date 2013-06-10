class Mdm::Module::Arch < ActiveRecord::Base
  self.table_name = 'module_archs'

  #
  # Associations
  #

  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Validations
  #

  validates :instance, :presence => true
  validates :name,
            :presence => true,
            :uniqueness => {
                :scope => :detail_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_arch, self)
end
