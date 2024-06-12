# Macro of {#actions} to run at once.
class Mdm::Macro < ApplicationRecord
  extend MetasploitDataModels::SerializedPrefs

  #
  # Attributes
  #

  # @!attribute created_at
  #   When this macro was created.
  #
  #   @return [DateTime]

  # @!attribute description
  #   Long description of what the macro does.
  #
  #   @return [String]

  # @!attribute  name
  #   The name of this macro.
  #
  #   @return [String]

  # @!attribute owner
  #   {Mdm::User#username Name of user} that owns this macro.
  #
  #   @return [String]

  # @!attribute updated_at
  #   When this macro was last updated.
  #
  #   @return [DateTime]

  #
  # Serialization
  #

  # Actions run by this macro.
  #
  # @return [Array<Hash{Symbol=>Object}>] Array of action hashes.  Each action hash is have key :module with value
  #   of an {Mdm::Module::Detail#fullname} and and key :options with value of options used to the run the module.
  if ActiveRecord::VERSION::MAJOR >= 7 && ActiveRecord::VERSION::MINOR >= 1
    serialize :actions, coder: MetasploitDataModels::Base64Serializer.new
  else
    serialize :actions, MetasploitDataModels::Base64Serializer.new
  end

  # Preference for this macro, shared across all actions.
  #
  # @return [Hash]
  if ActiveRecord::VERSION::MAJOR >= 7 && ActiveRecord::VERSION::MINOR >= 1
    serialize :prefs, coder: MetasploitDataModels::Base64Serializer.new
  else
    serialize :prefs, MetasploitDataModels::Base64Serializer.new
  end

  # The maximum number of seconds that this macro is allowed to run.
  #
  # @return [Integer]
  serialized_prefs_attr_accessor :max_time

  #
  # Validations
  #

  validates :name, :presence => true, :format => /\A[^'|"]+\z/

  Metasploit::Concern.run(self)
end

