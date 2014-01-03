source 'https://rubygems.org'

# Specify your gem's dependencies in metasploit_data_models.gemspec
gemspec

# used by dummy application
group :development, :test do
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryGirl.' in factory definitions syntax.
  gem 'factory_girl', '>= 4.1.0'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'
  # Used to create fake data
  gem 'faker'
  # Needs to be defined here because runtime dependencies from gemspec will not load for rspec environment
  # @todo Change back to `gem 'metasploi-model', '~> <X>.<Y>.<Z>'` once metasploit-model version X.Y.Z is released to rubygems.
  gem 'metasploit-model', :git => 'git://github.com/rapid7/metasploit-model.git', :tag => 'v0.19.4.eager_load'
  # rails is only used for the dummy application in spec/dummy
  # restrict from rails 4.0 as it requires protected_attributes gem and other changes for compatibility
  # @see https://www.pivotaltracker.com/story/show/52309083
  gem 'rails', '>= 3.2', '< 4.0.0'
  # tests compatibility with main progress bar target
  gem 'ruby-progressbar'
end

group :documentation do
  # Entity-Relationship diagrams for developers that need to access database using SQL directly.
  gem 'rails-erd'
  # for generating documentation
  gem 'yard'

  platforms :jruby do
    # markdown formatting for yard
    gem 'kramdown'
  end

  platforms :ruby do
    # markdown formatting for yard
    gem 'redcarpet'
  end
end

group :test do
  # used for building markup for webpage factories
  gem 'builder'
  # for cleaning the database before suite in case previous run was aborted without clean up
  gem 'database_cleaner'
  # need rspec-core >= 2.14.0 because 2.14.0 introduced RSpec::Core::SharedExampleGroup::TopLevel
  gem 'rspec-core', '>= 2.14.0'
  # need rspec-rails >= 2.12.0 as 2.12.0 adds support for redefining named subject in nested context that uses the
  # named subject from the outer context without causing a stack overflow.
  gem 'rspec-rails', '>= 2.12.0'
  # In a full rails project, factory_girl_rails would be in both the :development, and :test group, but since we only
  # want rails in :test, factory_girl_rails must also only be in :test.
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations
  gem 'shoulda-matchers'
  # code coverage of tests
  gem 'simplecov', :require => false
end
