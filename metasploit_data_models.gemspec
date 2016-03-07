# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'metasploit_data_models/version'

Gem::Specification.new do |s|
  s.name        = 'metasploit_data_models'
  s.version     = MetasploitDataModels::VERSION
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
  s.require_paths = %w{app/models app/validators lib}

  s.required_ruby_version = '>= 2.1'

  # ---- Dependencies ----
  # documentation
  s.add_development_dependency 'metasploit-yard', '~> 1.1'
  s.add_development_dependency 'yard-activerecord', '~> 0.0.14'
  # embed ERDs on index, namespace Module and Class<ActiveRecord::Base> pages
  s.add_development_dependency 'yard-metasploit-erd', '~> 1.1'

  s.add_development_dependency 'rake'

  # documentation
  # @note 0.8.7.4 has a bug where attribute writers show up as undocumented
  s.add_development_dependency 'yard', '< 0.8.7.4'
  # debugging
  s.add_development_dependency 'pry'

  rails_version_constraints = ['>= 4.0.9', '< 4.1.0']

  s.add_runtime_dependency 'activerecord', *rails_version_constraints
  s.add_runtime_dependency 'activesupport', *rails_version_constraints
  s.add_runtime_dependency 'metasploit-concern', '~> 1.1'
  s.add_runtime_dependency 'metasploit-model', '~> 1.1'
  s.add_runtime_dependency 'railties', *rails_version_constraints

  # os fingerprinting
  s.add_runtime_dependency 'recog', '~> 2.0'

  # arel-helpers: Useful tools to help construct database queries with ActiveRecord and Arel.
  s.add_runtime_dependency 'arel-helpers'

  # Fixes a problem with arel not being able to visit IPAddr nodes
  s.add_runtime_dependency 'postgres_ext'

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
