# Stores the load paths used by Msf::ModuleManager#add_module_path (with symbolic {#name names}) so that the module path
# directories can be moved, but the cached metadata in {Mdm::Module::Detail} and its associations can remain valid by
# just changing the Mdm::Module::Path records in the database.
class Mdm::Module::Path < ActiveRecord::Base
  self.table_name = 'module_paths'

  #
  # Associations
  #

  # @!attribute [rw] details
  #   The modules that use this as a {Mdm::Module::Detail#parent_path}.
  #
  #   @return [Array<Mdm::Module::Detail>]
  has_many :details, :class_name => 'Mdm::Module::Detail', :dependent => :destroy, :foreign_key => :parent_path_id

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

  before_validation :nilify_blanks
  before_validation :normalize_real_path

  #
  # Validations
  #

  validate :gem_and_name
  validates :name,
            :uniqueness => {
                :allow_nil => true,
                :scope => :gem
            }
  validates :real_path,
            :directory => true,
            :presence => true,
            :uniqueness => true

  #
  # Methods
  #

  private

  # Validates that either both {#gem} and {#name} are present or both are `nil`.
  def gem_and_name
    if name.present? and gem.blank?
      errors[:gem] << "can't be blank if name is present"
    end

    if gem.present? and name.blank?
      errors[:name] << "can't be blank if gem is present"
    end
  end

  # Converts blank {#gem} and/or {#name} to `nil`.
  #
  # @return [void]
  def nilify_blanks
    [:gem, :name].each do |attribute|
      value = send(attribute)

      if value.blank?
        send("#{attribute}=", nil)
      end
    end
  end

  def normalize_real_path
    if real_path and File.exist?(real_path)
      self.real_path = File.realpath(real_path)
    end
  end
end