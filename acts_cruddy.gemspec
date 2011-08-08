# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_cruddy/version"

Gem::Specification.new do |s|
  s.name        = "acts_cruddy"
  s.version     = ActsCruddy::VERSION
  s.authors     = [ "Topsail Technologies, Inc.", "Mark Roghelia" ]
  s.email       = ["mroghelia@topsailtech.com"]
  s.summary     = %q{Implmentation for CRUD actions}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
