# User settings.
class Mdm::Profile < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] active
  #   Whether this is the currently active profile.
  #
  #   @return [true] if this is the active profile.
  #   @return [false] if this profile is inactive and another profile is active.

  # @!attribute [rw] created_at
  #   When this profile was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] name
  #   Name of this profile to distinguish it from other profiles.
  #
  #   @return [String]

  # @!attribute [rw] owner
  #   Owner of this profile.
  #
  #   @return ['<system>'] System-wide profile for all users.
  #   @return [String] Name of user that uses this profile.

  # @!attribute [rw] updated_at
  #   The last time this profile was updated.
  #
  #   @return [DateTime]

  #
  # Serializations
  #

  # @!attribute [rw] settings
  #   Global settings.
  #
  #   @return [Hash]
  serialize :settings, MetasploitDataModels::Base64Serializer.new

  ActiveSupport.run_load_hooks(:mdm_profile, self)
end

