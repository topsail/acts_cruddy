# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "topsail/crud/version"

Gem::Specification.new do |s|
  s.name        = "topsail_crud"
  s.version     = Topsail::Crud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Topsail Technologies, Inc.", "Mark Roghelia"]
  s.email       = ["mroghelia@topsailtech.com"]
  s.homepage    = ""
  s.summary     = %q{Provides basic create, request, update and delete actions for a controller.}
  s.description = %q{TODO: Write a gem description}
  s.license     = %q{MIT}
  
  s.add_dependency 'rails', '~> 3.0'

  s.rubyforge_project = "acts_as_crud"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
