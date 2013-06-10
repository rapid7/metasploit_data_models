class Mdm::Module::Author < ActiveRecord::Base
  include MetasploitDataModels::NilifyBlanks

  self.table_name = 'module_authors'

  #
  # Associations
  #

  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Callbacks
  #

  nilify_blank :email

  #
  # Mass Assignment Security
  #

  attr_accessible :email
  attr_accessible :name

  #
  # Validations
  #

  validates :module_instance, :presence => true
  validates :name,
            :presence => true,
            :uniqueness => {
                :scope => :detail_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_author, self)
end
