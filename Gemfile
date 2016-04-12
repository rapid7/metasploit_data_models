source "https://rubygems.org"

# Specify your gem's dependencies in metasploit_data_models.gemspec
gemspec


gem 'metasploit-yard',        github: 'rapid7/metasploit-yard',        branch: 'staging/rails-upgrade'
gem 'metasploit-erd',         github: 'rapid7/metasploit-erd',         branch: 'staging/rails-upgrade'
gem 'yard-metasploit-erd',    github: 'rapid7/yard-metasploit-erd',    branch: 'staging/rails-upgrade'
gem 'metasploit-concern',     github: 'rapid7/metasploit-concern',     branch: 'staging/rails-upgrade'
gem 'metasploit-model',       github: 'rapid7/metasploit-model',       branch: 'staging/rails-upgrade'

group :development do
  #gem 'metasploit-erd'
  # embed ERDs on index, namespace Module and Class<ActiveRecord::Base> pages
  #gem 'yard-metasploit-erd'
end

# used by dummy application
group :development, :test do
  # Upload coverage reports to coveralls.io
  gem 'coveralls', require: false  
  # supplies factories for producing model instance for specs
  # Version 4.1.0 or newer is needed to support generate calls without the 'FactoryGirl.' in factory definitions syntax.
  gem 'factory_girl'
  # running documentation generation tasks and rspec tasks
  gem 'rake'
  # auto-load factories from spec/factories
  gem 'factory_girl_rails'


  gem 'rails', '~>4.1.15'
  # Used to create fake data
  gem "faker"
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
