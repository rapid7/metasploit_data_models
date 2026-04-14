source "https://rubygems.org"

# Specify your gem's dependencies in metasploit_data_models.gemspec
gemspec

# used by dummy application
group :development, :test do
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryBot.' in factory definitions syntax.
  gem 'factory_bot'
  # auto-load factories from spec/factories
  gem 'factory_bot_rails'

  # Allow Rails 7.0 through 8.0 for upgrade compatibility
  gem 'rails', '>= 7.0', '< 8.1'
  gem 'net-smtp', require: false

  # Used to create fake data
  gem "faker"

  # bound to 0.20 for Activerecord 4.2.8 deprecation warnings:
  # https://github.com/ged/ruby-pg/commit/c90ac644e861857ae75638eb6954b1cb49617090
  gem 'pg'
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
  gem 'rspec-rails'
  # used for building markup for webpage factories
  gem 'builder'
end
