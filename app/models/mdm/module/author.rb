class Mdm::Module::Author < ActiveRecord::Base
  include MetasploitDataModels::NilifyBlanks

  self.table_name = 'module_authors'

  #
  # Associations
  #

  belongs_to :detail, :class_name => 'Mdm::Module::Detail'

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

  validates :detail, :presence => true
  validates :name,
            :presence => true,
            :uniqueness => {
                :scope => :detail_id
            }

  ActiveSupport.run_load_hooks(:mdm_module_author, self)
end
