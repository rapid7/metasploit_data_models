#
# Core
#
require 'shellwords'

#
# Gems
#
require 'active_record'
require 'active_support'
require 'active_support/all'
require 'active_support/dependencies'
require 'awesome_nested_set'
require 'metasploit/model'

#
# Project
#
require 'mdm'
require 'mdm/module'
require 'metasploit_data_models/base64_serializer'
require 'metasploit_data_models/version'
require 'metasploit_data_models/serialized_prefs'

# Only include the Rails engine when using Rails.  This allows the non-Rails projects, like metasploit-framework to use
# the models by calling MetasploitDataModels.require_models.
if defined? Rails
  require 'metasploit_data_models/engine'
end

# Namespace module for the metasploit_data_models gems.
module MetasploitDataModels
  extend Metasploit::Model::Configured

  lib_pathname = Pathname.new(__FILE__).dirname
  configuration.root = lib_pathname.parent
end

MetasploitDataModels.setup
