# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

# Require simplecov before loading ..dummy/config/environment.rb because it will cause metasploit_data_models/lib to
# be loaded, which would result in Coverage not recording hits for any of the files.
require 'simplecov'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# full backtrace in logs so its easier to trace errors
Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
support_glob = MetasploitDataModels.root.join('spec', 'support', '**', '*.rb')

Dir.glob(support_glob) do |path|
  require path
end

RSpec.configure do |config|
  config.before(:suite) do
    # clean database of any records left-over from a previously aborted suite.
    DatabaseCleaner.clean_with(:truncation)

    # Run seeds, but not using rake db:seeds so seeds will populate test database when using `rake spec` _OR_ `rspec` to
    # run a subset of specs.
    load MetasploitDataModels.root.join('db', 'seeds.rb')

    MetasploitDataModels::Spec.temporary_pathname = MetasploitDataModels.root.join('spec', 'tmp')
    # Clean up any left over files from a previously aborted suite
    MetasploitDataModels::Spec.remove_temporary_pathname
  end

  config.before(:each) do
    # Rex is only available when testing with metasploit-framework or pro, so stub out the methods that require it
    Mdm::Workspace.any_instance.stub(:valid_ip_or_range? => true)
  end

  config.after(:each) do
    MetasploitDataModels::Spec.remove_temporary_pathname
  end

  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.order = :random
end
