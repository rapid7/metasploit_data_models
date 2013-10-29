# {Mdm::Module::Instance#platforms Platforms} for {Mdm::Module::Instance modules}.
class Mdm::Platform < ActiveRecord::Base
  include Metasploit::Model::Platform

  acts_as_nested_set dependent: :destroy,
                     left_column: :left,
                     right_column: :right,
                     order: :fully_qualified_name

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] module_platforms
  #   Joins this {Mdm::Platform} to {Mdm::Module::Instance modules} that support the platform.
  #
  #   @return [Array<Mdm::Module::Platform>]
  has_many :module_platforms, :class_name => 'Mdm::Module::Platform', :dependent => :destroy

  # @!attribute [rw] target_platforms
  #   Joins this to {Mdm::Module::Target targets} that support this platform.
  #
  #   @return [Array<Mdm::Module::Target::Platform>]
  has_many :target_platforms, class_name: 'Mdm::Module::Target::Platform', dependent: :destroy

  #
  # :through => :module_platforms
  #

  # @!attribute [r] module_instance
  #   {Mdm::Module::Instance Modules} that has this {Mdm::Platform} as one of their supported
  #   {Mdm::Module::Instance#platforms platforms}.
  #
  #   @return [Array<Mdm::Module::Instance>]
  has_many :module_instances, :class_name => 'Mdm::Module::Instance', :through => :module_platforms

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of the platform
  #
  #   @return [String]

  ActiveSupport.run_load_hooks(:mdm_platform, self)
end