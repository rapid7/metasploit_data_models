require 'metasploit/model'

module MetasploitDataModels
  # Helpers for loading models (and their validators) in a non-Rails environment, such as in metasploit-framework.
  #
  # @example loading models
  #   # Gemfile
  #   gem 'metasploit_data_models'
  #
  #   # main.rb
  #   MetasploitDataModels.require_models
  module Models
    # Pathname to the app/models directory.
    #
    # @return [Pathname]
    def models_pathname
      app_pathname.join('models')
    end

    # Requires all ruby files in {#models_pathname}.
    #
    # @return [void]
    def require_models
      Metasploit::Model.autoload_validators

      models_globs = models_pathname.join('**', '*.rb')

      Dir.glob(models_globs) do |model_path|
        require model_path
      end
    end
  end
end