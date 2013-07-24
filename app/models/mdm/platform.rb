# {Mdm::Module::Instance#platforms Platforms} for {Mdm::Module::Instance modules}.
class Mdm::Platform < ActiveRecord::Base
  include Metasploit::Model::Platform

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

  #
  # Validation
  #

  validates :name,
            :uniqueness => true

  ActiveSupport.run_load_hooks(:mdm_platform, self)
end