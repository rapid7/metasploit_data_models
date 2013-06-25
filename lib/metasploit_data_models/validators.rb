module MetasploitDataModels
  # Defines methods to help with loading validators outside of Rails, such as in metasploit-framework.
  module Validators
    # Mimics behavior of `app/validators` in Rails projects by adding it to
    # `ActiveSupport::Dependencies.autoload_paths` if it is not already in the Array.
    #
    # @return [void]
    def autoload_validators
      validators_path = validators_pathname.to_s

      unless ActiveSupport::Dependencies.autoload_paths.include? validators_path
        ActiveSupport::Dependencies.autoload_paths << validators_path
      end
    end

    # Pathname to app/validators.
    #
    # @return [Pathanme]
    def validators_pathname
      app_pathname.join('validators')
    end
  end
end