source "http://rubygems.org"

# Specify your gem's dependencies in metasploit_data_models.gemspec
gemspec

# used by dummy application
group :development, :test do
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryGirl.' in factory definitions syntax.
  gem 'factory_girl', '>= 4.1.0'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'
  # rails is only used for the dummy application in spec/dummy
  # restrict from rails 4.0 as it requires protected_attributes gem and other changes for compatibility
  # @see https://www.pivotaltracker.com/story/show/52309083
  gem 'rails', '>= 3.2', '< 4.0.0'
end

group :test do
  # In a full rails project, factory_girl_rails would be in both the :development, and :test group, but since we only
  # want rails in :test, factory_girl_rails must also only be in :test.
  # add matchers from shoulda, such as validates_presence_of, which are useful for testing validations
  gem 'shoulda-matchers'
  # code coverage of tests
  gem 'simplecov', :require => false
  # need rspec-rails >= 2.12.0 as 2.12.0 adds support for redefining named subject in nested context that uses the
  # named subject from the outer context without causing a stack overflow.
  gem 'rspec-rails', '>= 2.12.0'
  # used for building markup for webpage factories
  gem 'builder'
end
