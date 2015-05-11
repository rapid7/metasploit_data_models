require 'rails'

# `Rails::Engine` that exposes MetasploitDataModel's `ActiveRecord::Base` subclasses and automatically loads its
# `FactoryGirl` factories, sequences, and traits.
class MetasploitDataModels::Engine < Rails::Engine
  # @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
  config.generators do |g|
    g.assets false
    g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    g.helper false
    g.test_framework :rspec, :fixture => false
  end

  # Remove ActiveSupport::Dependencies loading paths to save time during constant resolution and to ensure that
  # metasploit_data_models is properly declaring all autoloads and not falling back on ActiveSupport::Dependencies
  config.paths.values.each do |path|
    path.skip_autoload!
    path.skip_autoload_once!
    path.skip_eager_load!
    path.skip_load_path!
  end

  initializer 'metasploit_data_models.prepend_factory_path', :after => 'factory_girl.set_factory_paths' do
    if defined? FactoryGirl
      relative_definition_file_path = config.generators.options[:factory_girl][:dir]
      definition_file_path = root.join(relative_definition_file_path)

      # unshift so that Pro can modify mdm factories
      FactoryGirl.definition_file_paths.unshift definition_file_path
    end
  end
end