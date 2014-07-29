# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'metasploit_data_models/version'

Gem::Specification.new do |s|
  s.name        = 'metasploit_data_models'
  s.version     = MetasploitDataModels::GEM_VERSION
  s.authors     = [
      'Samuel Huckins',
      'Luke Imhoff',
      "David 'thelightcosine' Maloney",
      "Trevor 'burlyscudd' Rosen"
  ]
  s.email       = [
      'shuckins@rapid7.com',
      'luke_imhoff@rapid7.com',
      'dmaloney@rapid7.com',
      'trevor_rosen@rapid7.com'
  ]
  s.homepage    = ""
  s.summary     = %q{Database code for MSF and Metasploit Pro}
  s.description = %q{Implements minimal ActiveRecord models and database helper code used in both the Metasploit Framework (MSF) and Metasploit commercial editions.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # ---- Dependencies ----
  s.add_development_dependency 'rake'

  # documentation
  # @note 0.8.7.4 has a bug where attribute writers show up as undocumented
  s.add_development_dependency 'yard', '< 0.8.7.4'
  # debugging
  s.add_development_dependency 'pry'

  # restrict from rails 4.0 as it requires protected_attributes gem and other changes for compatibility
  # @see MSP-2971
  s.add_runtime_dependency 'activerecord', '>= 3.2.13', '< 4.0.0'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'metasploit-concern', '~> 0.1.0'
  s.add_runtime_dependency 'metasploit-model', '~> 0.26.1'
  
  # arel-helpers: Useful tools to help construct database queries with ActiveRecord and Arel.
  s.add_runtime_dependency 'arel-helpers'
  
  if RUBY_PLATFORM =~ /java/
    # markdown formatting for yard
    s.add_development_dependency 'kramdown'

    s.add_runtime_dependency 'jdbc-postgres'
    s.add_runtime_dependency 'activerecord-jdbcpostgresql-adapter'
    
    s.platform = Gem::Platform::JAVA
  else
    # markdown formatting for yard
    s.add_development_dependency 'redcarpet'

    s.add_runtime_dependency 'pg'
    
    s.platform = Gem::Platform::RUBY
  end
end
