require 'metasploit_data_models/validators'

module MetasploitDataModels
  module Models
    include MetasploitDataModels::Validators
    extend ActiveSupport::Autoload

    autoload :MetasploitDataModels

    def models_pathname
      app_pathname.join('models')
    end

    def require_models
      autoload_validators

#      models_globs = models_pathname.join('**', '*.rb')
#
#      Dir.glob(models_globs) do |model_path|
#        require model_path
#      end
    end
  end
end
