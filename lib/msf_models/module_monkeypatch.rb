# 2011-12-30
# Enables selectively adding modules/classes into a given namespace
#
# Shamelessly ripped off from:
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/230125
#
# This is because MSF namespaces ActiveRecord model classes, but the 
# commercial versions of Metasploit do not.

class Module

  # Load file into module/class namespace.
  def module_load( path )
    if path =~ /^[\/~.]/
      file = File.expand_path(path)
    else
      $LOAD_PATH.each do |lp|
        file = File.join(lp,path)
        break if File.exist?(file)
        file = nil
      end
    end

    module_eval(File.read(file))
  end

  # Require file into module/class namespace.
  def module_require( path )
    if path =~ /^[\/~.]/
      file = File.expand_path(path)
    else
      $LOAD_PATH.each do |lp|
        file = File.join(lp,path)
        break if File.exist?(file)
        file += '.rb'
        break if File.exist?(file)
        file = nil
      end
    end

    @loaded ||= {}
    if @loaded.key?(file)
      false
    else
      @loaded[file] = true
      module_eval(File.read(file))
      true
    end
  end

end


class Class
  alias class_load module_load
  alias class_require module_require
end
