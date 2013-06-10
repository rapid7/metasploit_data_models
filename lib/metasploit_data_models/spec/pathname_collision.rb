module MetasploitDataModels
  module Spec
    # Error raised if a pathname already exists on disk when one of the real_paths for metasploit_data_models factories
    # is generated or derived, which would indicate that a prior spec did not clean up properly.
    class PathnameCollision < MetasploitDataModels::Spec::Error
      # Checks if there is a pathname collision.
      #
      # @param (see #initialize)
      # @return [void]
      # @raise [MetasploitDataModels::Spec::PathnameCollision] if `pathname.exist?` is `true`.
      def self.check!(pathname)
        if pathname.exist?
          raise new(pathname)
        end
      end

      # @param pathname [Pathname] Pathname that already exists on disk
      def initialize(pathname)
        super(
            "#{pathname} already exists.  " \
            "MetasploitDataModels::Spec.remove_temporary_pathname was not called after the previous spec."
        )
      end
    end
  end
end