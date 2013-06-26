# Macro of {#actions} to run at once.
class Mdm::Macro < ActiveRecord::Base
  extend MetasploitDataModels::SerializedPrefs

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this macro was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] description
  #   Long description of what the macro does.
  #
  #   @return [String]

  # @!attribute [rw] name
  #   The name of this macro.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52402715

  # @!attribute [rw] owner
  #   {Mdm::User#username Name of user} that owns this macro.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52402533

  # @!attribute [rw] updated_at
  #   When this macro was last updated.
  #
  #   @return [DateTime]

  #
  # Serialization
  #

  # @!attribute [rw] actions
  #   Actions run by this macro.
  #
  #   @return [Array<Hash{Symbol=>Object}>] Array of action hashes.  Each action hash is have key :module with value
  #     of an {Mdm::Module::Class#full_name} and and key :options with value of options used to the run the module.
  #   @todo https://www.pivotaltracker.com/story/show/52410417
  serialize :actions, MetasploitDataModels::Base64Serializer.new

  # @!attribute [rw] prefs
  #   Preference for this macro, shared across all actions.
  #
  #   @return [Hash]
  serialize :prefs, MetasploitDataModels::Base64Serializer.new

  # @!attribute [rw] max_time
  #   The maximum number of seconds that this macro is allowed to run.
  #
  #   @return [Integer]
  serialized_prefs_attr_accessor :max_time

  #
  # Validations
  #

  validates :name, :presence => true, :format => /^[^'|"]+$/

  ActiveSupport.run_load_hooks(:mdm_macro, self)
end

