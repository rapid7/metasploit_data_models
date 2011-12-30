# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "msf_models/version"

Gem::Specification.new do |s|
  s.name        = "msf_models"
  s.version     = MsfModels::VERSION
  s.authors     = ["Trevor Rosen"]
  s.email       = ["trevor_rosen@rapid7.com"]
  s.homepage    = ""
  s.summary     = %q{Database code for MSF and Metasploit Pro}
  s.description = %q{Implements minimal ActiveRecord models and database helper code used in both the Metasploit Framework (MSF) and Metasploit commercial editions.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "pg"
end
