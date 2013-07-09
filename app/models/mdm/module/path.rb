# Stores the load paths used by Msf::ModuleManager#add_module_path (with symbolic {#name names}) so that the module path
# directories can be moved, but the cached metadata in {Mdm::Module::Ancestor} and its associations can remain valid by
# just changing the Mdm::Module::Path records in the database.
class Mdm::Module::Path < ActiveRecord::Base
  include Metasploit::Model::NilifyBlanks

  self.table_name = 'module_paths'

  #
  # Associations
  #

  # @!attribute [rw] module_ancestors
  #   The modules ancestors that use this as a {Mdm::Module::Ancestor#parent_path}.
  #
  #   @return [Array<Mdm::Module::Detail>]
  has_many :module_ancestors,
           :class_name => 'Mdm::Module::Ancestor',
           :dependent => :destroy,
           :foreign_key => :parent_path_id

  #
  # Attributes
  #

  # @!attribute [rw] gem
  #   The name of the gem that is adding this module path to metasploit-framework.  For paths normally added by
  #   metasploit-framework itself, this would be `'metasploit-framework'`, while for Metasploit Pro this would be
  #   `'metasploit-pro'`.  The name used for `gem` does not have to be a gem on rubygems, it just functions as a
  #   namespace for {#name} so that projects using metasploit-framework do not need to worry about collisions on
  #   {#name} which could disrupt the cache behavior.
  #
  #   @return [String]

  # @!attribute [rw] name
  #   The name of the module path scoped to {#gem}.  {#gem} and {#name} uniquely identify this path so that if
  #   {#real_path} changes, the entire cache does not need to be invalidated because the change in {#real_path} will
  #   still be tied to the same ({#gem}, {#name}) tuple.
  #
  #   @return [String]

  # @!attribute [rw] real_path
  #   @note Non-real paths will be converted to real paths in a before validation callback, so take care to either pass
  #   real paths or pay attention when setting {#real_path} and then changing directories before validating.
  #
  #   The real (absolute) path to module path.
  #
  #   @return [String]

  #
  # Callbacks - in calling order
  #

  nilify_blank :gem,
               :name
  before_validation :normalize_real_path
  after_update :update_module_ancestor_real_paths

  #
  # Mass Assignment Security
  #

  attr_accessible :gem
  attr_accessible :name
  attr_accessible :real_path

  #
  # Validations
  #

  validate :gem_and_name
  validates :name,
            :uniqueness => {
                :allow_nil => true,
                :scope => :gem,
                :unless => :add_context?
            }
  validates :real_path,
            :directory => true,
            :presence => true,
            :uniqueness => {
                :unless => :add_context?
            }

  #
  # Methods
  #

  # Returns whether is a named path.
  #
  # @return [false] if gem is blank or name is blank.
  # @return [true] if gem is not blank and name is not blank.
  def named?
    named = false

    if gem.present? and name.present?
      named = true
    end

    named
  end

  private

  # Returns whether #validation_context is `:add`.  If #validation_context is :add then the uniqueness validations on
  # :name and :real_path are skipped so that this path can be validated prior to looking for pre-existing
  # {Mdm::Module::Path paths} with either the same {#real_path} that needs to have its {#gem} and {#name} updated
  # {Mdm::Module::Path paths} with the same {#gem} and {#name} that needs to have its {#real_path} updated.
  #
  # @return [true] if uniqueness validations should be skipped.
  # @return [false] if normal create or update context.
  def add_context?
    if validation_context == :add
      true
    else
      false
    end
  end

  # Validates that either both {#gem} and {#name} are present or both are `nil`.
  #
  # @return [void]
  def gem_and_name
    if name.present? and gem.blank?
      errors[:gem] << "can't be blank if name is present"
    end

    if gem.present? and name.blank?
      errors[:name] << "can't be blank if gem is present"
    end
  end

  # If {#real_path} is set and exists on disk, then converts it to a real path to eliminate any symlinks.
  #
  # @return [void]
  # @see MetasploitDataModels::File.realpath
  def normalize_real_path
    if real_path and File.exist?(real_path)
      self.real_path = Metasploit::Model::File.realpath(real_path)
    end
  end

  # If {#real_path} changes, then update the {Mdm::Module::Ancestor#real_path} for {#module_ancestors}.
  #
  # @return [void]
  def update_module_ancestor_real_paths
    if real_path_changed?
      module_ancestors.each do |module_ancestor|
        module_ancestor.real_path = module_ancestor.derived_real_path

        module_ancestor.save!
      end
    end
  end
end