module MetasploitDataModels
  module Models
    def models_pathname
      app_pathname.join('models')
    end

    def require_models
      models_globs = models_pathname.join('**', '*.rb')

      Dir.glob(models_globs) do |model_path|
        require model_path
      end
    end
  end
end