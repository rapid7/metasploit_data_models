# Stores the load paths used by Msf::ModuleManager#add_module_path (with symbolic {#name names}) so that the module path
# directories can be moved, but the cached metadata in {Mdm::Module::Ancestor} and its associations can remain valid by
# just changing the Mdm::Module::Path records in the database.
class Mdm::Module::Path < ActiveRecord::Base
  include Metasploit::Model::Module::Path

  self.table_name = 'module_paths'

  #
  # Associations
  #

  # @!attribute [rw] module_ancestors
  #   The modules ancestors that use this as a {Mdm::Module::Ancestor#parent_path}.
  #
  #   @return [Array<Mdm::Module::Ancestor>]
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

  after_update :update_module_ancestor_real_paths

  #
  # Validations
  #

  validates :name,
            :uniqueness => {
                :allow_nil => true,
                :scope => :gem,
                :unless => :add_context?
            }
  validates :real_path,
            :uniqueness => {
                :unless => :add_context?
            }

  #
  # Methods
  #

  # Returns {Mdm::Module::Ancestor} at `real_path` under this module path if `real_path` has changed.
  #
  # @param real_path [String] real_path under {#real_path}.
  # @param options [Hash{Symbol => Object}]
  # @option options [Boolean] :changed (false) if `true`, assume the
  #   {Mdm::Module::Ancestor#real_path_modified_at} and
  #   {Mdm::Module::Ancestor#real_path_sha1_hex_digest} have changed and that
  #   {Mdm::Module::Ancestor} should be returned.
  # @return [nil] if {Mdm::Module::Ancestor#real_path_modified_at} has not changed.
  # @return [nil] if {Mdm::Module::Ancestor#real_path_modified_at} has changed, but
  #   {Mdm::Module::Ancestor#real_path_sha1_hex_digest} has not changed.
  # @return [Mdm::Module::Ancestor] if {Mdm::Module::Ancestor#real_path_modified_at}
  #   and {Mdm::Module::Ancestor#real_path_sha1_hex_digest} have changed.
  # @return [Mdm::Module::Ancestor] if `:changed` is `true`.
  # @raise [ActiveRecord::Invalid] if {Mdm::Module::Ancestor} is invalid when updating
  #   {Mdm::Module::Ancestor#real_path_modified_at} and
  #   {Mdm::Module::Ancestor#real_path_sha1_hex_digest}
  def changed_module_ancestor_from_real_path(real_path, options={})
    changed = options.fetch(:changed, false)
    module_ancestor = nil

    # ensure the connection doesn't stay checked out for thread in metasploit-framework.
    ActiveRecord::Base.connection_pool.with_connection do
      module_ancestor = module_ancestors.where(:real_path => real_path).first_or_initialize
      module_ancestor.real_path_modified_at = module_ancestor.derived_real_path_modified_at

      # only derive the SHA1 Hex Digest if modification time has changed to save time
      if module_ancestor.real_path_modified_at_changed?
        module_ancestor.real_path_sha1_hex_digest = module_ancestor.derived_real_path_sha1_hex_digest

        # have to check for change prior to saving as changes are reset after save
        changed ||= module_ancestor.real_path_sha1_hex_digest_changed?
      end

      module_ancestor.save!
    end

    if changed
      module_ancestor
    else
      nil
    end
  end

  # @note This path should be validated before calling {#name_collision} so that {#gem} and {#name} is normalized.
	#
	# Returns path with the same {#gem} and {#name}.
	#
	# @return [Mdm::Module::Path] if there is a {Mdm::Module::Path} with the same {#gem} and {#name} as this path.
	# @return [nil] if #named? is `false`.
	# @return [nil] if there is not match.
  def name_collision
    collision = nil

    # Don't query database if gem and name are `nil` since all unnamed paths will match.
    if named?
      collision = self.class.where(:gem => gem, :name => name).first
    end

    collision
  end

  # @note This path should be validated before calling {#real_path_collision} so that {#real_path} is normalized.
  #
  # Returns path with the same {#real_path}.
  #
  # @return [Mdm::Module::Path] if there is a {Mdm::Module::Path} with the same {#real_path} as this path.
  # @return [nil] if there is not match.
  def real_path_collision
    self.class.where(:real_path => real_path).first
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