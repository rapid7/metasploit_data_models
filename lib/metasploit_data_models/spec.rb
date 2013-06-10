module MetasploitDataModels
  # Helper methods for running specs for metasploit_data_models.
  #
  # @example Temporary pathname creation and removal
  #
  #   # spec/spec_helper.rb
  #   RSpec.config do |config|
  #     config.before(:suite) do
  #       MetasploitDataModels::Spec.temporary_pathname = MyApp.root.join('spec', 'tmp')
  #       # Clean up any left over files from a previously aborted suite
  #       MetasploitDataModels::Spec.remove_temporary_pathname
  #     end
  #
  #     config.after(:each) do
  #       MetasploitDataModels::Spec.remove_temporary_pathname
  #     end
  #   end
  module Spec
    # Removes {#temporary_pathname} from disk if it's been set and exists on disk.
    #
    # @return [void]
    def self.remove_temporary_pathname
      begin
        removal_pathname = temporary_pathname
      rescue MetasploitDataModels::Spec::Error
        removal_pathname = nil
      end

      if removal_pathname and removal_pathname.exist?
        removal_pathname.rmtree
      end
    end

    # Pathname to hold temporary files for metasploit_data_models factories and sequence.  The directory must be be
    # safely writable and removable for specs that need to use the file system.
    #
    # @return [Pathname]
    def self.temporary_pathname
      unless instance_variable_defined?(:@temporary_pathname)
        raise MetasploitDataModels::Spec::Error, "MetasploitDataModels::Spec.temporary_pathname not set prior to use"
      end

      @temporary_pathname
    end

    # Sets the pathname to use for temporary directories and files used in metasploit_data_models factories and
    # sequences.
    #
    # @param pathname [Pathname] path to a directory.  It does not need to exist, but need to be in a writable parent
    #   directory so it can be removed by {#remove_temporary_pathname}.
    # @return [Pathname] `pathname`
    def self.temporary_pathname=(pathname)
      @temporary_pathname = pathname
    end
  end
end