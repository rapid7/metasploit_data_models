# 2011-12-30
# Enables selectively adding modules/classes into a given namespace
#
# Shamelessly ripped off from:
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/230125
#
# This is because MSF namespaces ActiveRecord model classes, but the 
# commercial versions of Metasploit do not.

# TODO: code's a bit wooly and could do with a refactoring


class Module

  # Load file into module/class namespace.
  def module_load(module_path)
    file = File.expand_path(path) if path =~ /^[\/~.]/  # absolute path
    file ||= $LOAD_PATH.find { |lp| File.exist? File.join(lp, module_path) }
    module_eval(File.read(file))
  end

  # Require file into module/class namespace.
  def module_require(module_path)
    file = File.expand_path(path) if path =~ /^[\/~.]/
    # first check for module in the $LOAD_PATH
    file ||= $LOAD_PATH.find { |lp|  File.exist? File.join(lp, module_path) }
    # if not found check for module+'.rb' in the $LOAD_PATH
    file ||= $LOAD_PATH.map { |lp| lp+'.rb' }.find { |lp| File.exist?(File.join(lp, module_path)+'.rb') }

    # load only once, and return false if module is already loaded
    @loaded ||= {}
    already_loaded = @loaded.key?(file)
    
    unless already_loaded
      @loaded[file] = true
      module_eval(File.read(file)) 
    end
    
    !already_loaded
  end

end


class Class
  alias class_load module_load
  alias class_require module_require
end
