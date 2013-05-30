if RUBY_PLATFORM =~ /java/
  require 'java'
end

module MetasploitDataModels
  # Re-implement methods on ruby's File that are buggy in JRuby so that the platform specific logic can be in this
  # module instead of everywhere these methods are used.
  module File
    if RUBY_PLATFORM =~ /java/
      # On JRuby, File.realpath does not resolve symlinks, so need to drop to Java to get the real path.
      #
      # @param path [String] a path that may contain `'.'`, `'..'`, or symlinks
      # @return [String] canonical path
      # @see https://github.com/jruby/jruby/issues/538
      def self.realpath(path)
        file = java.io.File.new(path)

        file.canonical_path
      end
    else
      # On MRI Ruby, File.realpath does resolve symlinks, so just delegate to File.realpath.
      #
      # @param path [String] a path that may contain `'.'`, `'..'`, or symlinks
      # @return [String] canonical path
      def self.realpath(path)
        ::File.realpath(path)
      end
    end
  end
end