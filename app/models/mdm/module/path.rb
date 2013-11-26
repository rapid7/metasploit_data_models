#
# Gems
#

require 'file/find'

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
           class_name: 'Mdm::Module::Ancestor',
           dependent: :destroy,
           foreign_key: :parent_path_id,
           inverse_of: :parent_path

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

  # @note The yielded {Mdm::Module::Ancestor} may contain unsaved changes.  It is the responsibility of the caller to
  #   save the record and to populate the {Mdm::Module::Ancestor#handler_type} if the {Mdm::Module::Ancestor#handled?}
  #   is `true` because the {Mdm::Module::Ancestor#handler_type} can only be determined by loading the ancestor, not
  #   from the file system alone.
  #
  # @overload each_changed_module_ancestor(options={}, &block)
  #   Yields each module ancestor that is changed under this module path.
  #
  #   @yield [module_ancestor]
  #   @yieldparam module_ancestor [Mdm::Module::Ancestor] a changed, or in the case of `changed: true`,
  #     assumed changed, {Mdm::Module::Ancestor}.
  #   @yieldreturn [void]
  #   @return [void]
  #
  # @overload each_changed_module_ancestor(options={})
  #   Returns enumerator that yields each module ancestor that is changed under this module path.
  #
  #   @return [Enumerator]
  #
  # @param options [Hash{Symbol => Boolean}]
  # @option options [Boolean] :changed (false) if `true`, assume the
  #   {Mdm::Module::Ancestor#real_path_modified_at} and
  #   {Mdm::Module::Ancestor#real_path_sha1_hex_digest} have changed and that
  #   {Mdm::Module::Ancestor} should be returned.
  # @option options [ProgressBar, #total=, #increment] :progress_bar a ruby `ProgressBar` or similar object that
  #   supports the `#total=` and `#increment` API for monitoring the progress of the enumerator.  `#total` will be set
  #   to total number of {#module_ancestor_real_paths real paths} under this module path, not just the number of changed
  #   (updated or new) real paths.  `#increment` will be called whenever a real path is visited, which means it can be
  #   called when there is no yielded module ancestor because that module ancestor was unchanged.  When
  #   {#each_changed_module_ancestor} returns, `#increment` will have been called the same number of times as the value
  #   passed to `#total=` and `#finished?` will be `true`.
  #
  # @see #changed_module_ancestor_from_real_path
  def each_changed_module_ancestor(options={})
    options.assert_valid_keys(:changed, :progress_bar)

    unless block_given?
      to_enum(__method__, options)
    else
      real_paths = module_ancestor_real_paths

      progress_bar = options[:progress_bar] || MetasploitDataModels::NullProgressBar.new
      progress_bar.total = real_paths.length

      # ensure the connection doesn't stay checked out for thread in metasploit-framework.
      ActiveRecord::Base.connection_pool.with_connection do
        updatable_module_ancestors = module_ancestors.where(real_path: real_paths)
        new_real_path_set = Set.new(real_paths)
        assume_changed = options.fetch(:changed, false)

        # use find_each since this is expected to exceed default batch size of 1000 records.
        updatable_module_ancestors.find_each do |updatable_module_ancestor|
          new_real_path_set.delete(updatable_module_ancestor.real_path)

          changed = assume_changed

          # real_path_modified_at and real_path_sha1_hex_digest should be updated even if assume_changed is true so
          # that database says in-sync with file system

          updatable_module_ancestor.real_path_modified_at = updatable_module_ancestor.derived_real_path_modified_at

          # only derive the SHA1 Hex Digest if modification time has changed to save time
          if updatable_module_ancestor.real_path_modified_at_changed?
            updatable_module_ancestor.real_path_sha1_hex_digest = updatable_module_ancestor.derived_real_path_sha1_hex_digest

            changed ||= updatable_module_ancestor.real_path_sha1_hex_digest_changed?
          end

          if changed
            yield updatable_module_ancestor
            progress_bar.increment
          else
            # increment even when no yield so that increment occurs for each path and matches totally without jumps
            progress_bar.increment
          end
        end

        # after all pre-existing real_paths are subtracted, new_real_path_set contains only real_paths not in the
        # database
        new_real_path_set.each do |real_path|
          new_module_ancestor = module_ancestors.new(real_path: real_path)

          yield new_module_ancestor
          progress_bar.increment
        end
      end
    end
  end

  # `Metasploit::Model::Module::Ancestor#real_path` under {#real_path} on-disk.
  #
  # @return [Arrray<String>]
  def module_ancestor_real_paths
    module_ancestor_rule.find
  end

  # File::Find rule for find all `Metasploit::Model::Module::Ancestor#real_path` under {#real_path} on-disk.
  #
  # @return [File::Find]
  def module_ancestor_rule
    File::Find.new(
        ftype: 'file',
        path: real_path,
        pattern: "*#{Metasploit::Model::Module::Ancestor::EXTENSION}"
    )
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