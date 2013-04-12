class Mdm::Module::Detail < ActiveRecord::Base
  self.table_name = 'module_details'

  #
  # Associations
  #

  has_many :actions,   :class_name => 'Mdm::Module::Action',   :dependent => :destroy
  has_many :archs,     :class_name => 'Mdm::Module::Arch',     :dependent => :destroy
  has_many :authors,   :class_name => 'Mdm::Module::Author',   :dependent => :destroy
  has_many :mixins,    :class_name => 'Mdm::Module::Mixin',    :dependent => :destroy
  has_many :platforms, :class_name => 'Mdm::Module::Platform', :dependent => :destroy
  has_many :refs,      :class_name => 'Mdm::Module::Ref',      :dependent => :destroy
  has_many :targets,   :class_name => 'Mdm::Module::Target',   :dependent => :destroy

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
