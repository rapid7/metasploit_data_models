begin
  require 'rails'
# Metasploit::Model.configuration.autoload.eager_load! will load this file, but if rails is not available, it should not
# break the caller of eager_load! (i.e. metasploit-framework)
rescue LoadError => error
  warn "rails could not be loaded, so MetasploitDataModels::Engine will not be defined: #{error}"
else
  module MetasploitDataModels
    # Rails engine for MetasploitDataModels.  Will automatically be used if `Rails` is defined when
    # 'metasploit_data_models' is required, as should be the case in any normal Rails application Gemfile where
    # gem 'rails' is the first gem in the Gemfile.
    class Engine < Rails::Engine
      # @see http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
      config.generators do |g|
        g.assets false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.helper false
        g.test_framework :rspec, :fixture => false
      end

      # Order so that paths are ordered
      # 1. metasploit-model
      # 2. metasploit_data_models
      # 3. pro
      initializer('metasploit_data_models.prepend_factory_path',
                  # after factory girl so pro's path (which factory_girl would add when it is run in pro) is already in
                  # definition_file_paths
                  :after => 'factory_girl.set_factory_paths',
                  # make sure to run before metasploit-model so that metasploit_data_models' path is added in front of
                  # pro's and then metasploit-model is added in front of metasploit_data_models's path.
                  :before => 'metasploit_model.prepend_factory_path'
      ) do
        if defined? FactoryGirl
          relative_definition_file_path = config.generators.options[:factory_girl][:dir]
          definition_file_path = root.join(relative_definition_file_path)

          # unshift so that Pro can modify mdm factories
          FactoryGirl.definition_file_paths.unshift definition_file_path
        end
      end
    end
  end
end
