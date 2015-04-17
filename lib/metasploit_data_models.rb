#
# Core
#
require 'shellwords'

#
# Gems
#
# gems must load explicitly any gem declared in gemspec
# @see https://github.com/bundler/bundler/issues/2018#issuecomment-6819359
#
#
require 'active_record'
require 'active_support'
require 'active_support/all'
require 'metasploit/concern'
require 'metasploit/model'
require 'arel-helpers'
require 'postgres_ext'
require 'protected_attributes'

#
# Project
#

require 'metasploit_data_models/version'

autoload :Mdm, 'mdm'

module MetasploitDataModels
  extend ActiveSupport::Autoload

  autoload :AutomaticExploitation
  autoload :Base64Serializer
  autoload :ChangeRequiredColumnsToNullFalse
  autoload :IPAddress
  autoload :Match
  autoload :ModuleRun
  autoload :Search
  autoload :SerializedPrefs

  def self.root
    unless instance_variable_defined? :@root
      lib_pathname = Pathname.new(__FILE__).dirname

      @root = lib_pathname.parent
    end

    @root
  end
end

