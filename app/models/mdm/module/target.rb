# A potential target for a {Mdm::Module::Instance module}.  Targets can change options including offsets for ROP chains
# to tune an exploit to work with different system libraries and versions.
class Mdm::Module::Target < ActiveRecord::Base
  include Metasploit::Model::Module::Target

  self.table_name = 'module_targets'

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   Module where this target was declared.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, :class_name => 'Mdm::Module::Instance'

  #
  # Attributes
  #

  # @!attribute [rw] index
  #   Index of this target among other {Mdm::Module::Instance#targets targets} for {#module_instance}.  The default
  #   target is usually specified by index in the module code, so the indices for targets is mirror here for easier
  #   correlation.  The default target is an {Mdm::Module::Instance#default_target association} on
  #   {Mdm::Module::Instance}, not an index like in the code for easier reporting and searching using the database.
  #
  #   @return [Integer]

  # @!attribute [rw] name
  #   The name of this target.
  #
  #   @return [String]

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
