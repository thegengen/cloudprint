# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloudprint/version"

Gem::Specification.new do |s|
  s.name        = "cloudprint"
  s.version     = Cloudprint::VERSION
  s.authors     = ["Eugen Minciu"]
  s.email       = ["eugen@lesseverything.com"]
  s.homepage    = "http://github.com/minciue/cloudprint"
  s.licenses    = ["MIT"]
  s.summary     = "This library provides a ruby-esque interface to Google Cloud Print."
  s.description = <<-DESC
This library provides a ruby-esque interface to Google Cloud Print.
cloudprint is a work in progress. I'll be adding documentation once all the basic GCP functionality is supported."
DESC

  s.add_dependency 'oauth2', '~> 0.8.0'
  s.add_dependency 'json'

  s.add_development_dependency 'mocha', '~> 0.10.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'test-unit'

  s.rubyforge_project = "cloudprint"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
