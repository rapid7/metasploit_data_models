# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'metasploit_data_models/version'

Gem::Specification.new do |s|
  s.name        = 'metasploit_data_models'
  s.version     = MetasploitDataModels::VERSION
  s.authors     = ['Metasploit Hackers']
  s.email       = ['msfdev@metasploit.com']
  s.homepage    = ""
  s.summary     = %q{Database code for MSF and Metasploit Pro}
  s.description = %q{Implements minimal ActiveRecord models and database helper code used in both the Metasploit Framework (MSF) and Metasploit commercial editions.}

  s.files         = `git ls-files`.split("\n").reject { |file|
    file =~ /^bin/
  }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = %w{app/models app/validators lib}

  s.required_ruby_version = '>= 2.7'

  # ---- Dependencies ----
  # documentation
  s.add_development_dependency 'metasploit-yard'
  s.add_development_dependency 'yard-activerecord'
  # embed ERDs on index, namespace Module and Class<ApplicationRecord> pages
  s.add_development_dependency 'yard-metasploit-erd'

  s.add_development_dependency 'rake'

  s.add_development_dependency 'yard'
  # debugging
  s.add_development_dependency 'pry'


  s.add_runtime_dependency 'activerecord', '~>7.0'
  s.add_runtime_dependency 'activesupport', '~>7.0'
  s.add_runtime_dependency 'metasploit-concern'
  s.add_runtime_dependency 'metasploit-model', '~>5.0.4'
  s.add_runtime_dependency 'railties', '~>7.0'
  s.add_runtime_dependency 'webrick'

  # os fingerprinting
  s.add_runtime_dependency 'recog'

  # arel-helpers: Useful tools to help construct database queries with ActiveRecord and Arel.
  s.add_runtime_dependency 'arel-helpers'

  # Standard libraries: https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-3-0-released/
  %w[
    bigdecimal
    drb
    mutex_m
  ].each do |library|
    s.add_runtime_dependency library
  end

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
