class Mdm::ModuleDetail < ActiveRecord::Base
  self.table_name = 'module_details'

  #
  # Associations
  #

  has_many :actions,   :class_name => 'Mdm::ModuleAction',   :dependent => :destroy, :source => :module_action
  has_many :archs,     :class_name => 'Mdm::ModuleArch',     :dependent => :destroy, :source => :module_arch
  has_many :authors,   :class_name => 'Mdm::ModuleAuthor',   :dependent => :destroy, :source => :module_author
  has_many :mixins,    :class_name => 'Mdm::ModuleMixin',    :dependent => :destroy, :source => :module_mixin
  has_many :platforms, :class_name => 'Mdm::ModulePlatform', :dependent => :destroy, :source => :module_platform
  has_many :refs,      :class_name => 'Mdm::ModuleRef',      :dependent => :destroy, :source => :module_ref
  has_many :targets,   :class_name => 'Mdm::ModuleTarget',   :dependent => :destroy, :source => :module_target

  #
  # Validations
  #

  validates :refname,   :presence => true

  validates_associated :actions
  validates_associated :archs
  validates_associated :authors
  validates_associated :mixins
  validates_associated :platforms
  validates_associated :refs
  validates_associated :targets

  def add_action(name)
    self.actions.build(:name => name).save
  end

  def add_arch(name)
    self.archs.build(:name => name).save
  end

  def add_author(name, email=nil)
    self.authors.build(:name => name, :email => email).save
  end

  def add_mixin(name)
    self.mixins.build(:name => name).save
  end

  def add_platform(name)
    self.platforms.build(:name => name).save
  end

  def add_ref(name)
    self.refs.build(:name => name).save
  end

  def add_target(index, name)
    self.targets.build(:index => index, :name => name).save
  end

  ActiveSupport.run_load_hooks(:mdm_module_detail, self)
end
