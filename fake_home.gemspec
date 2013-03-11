# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_home/version'

Gem::Specification.new do |spec|
  spec.name          = "fake_home"
  spec.version       = FakeHome::VERSION
  spec.authors       = ["DSIW"]
  spec.email         = ["dsiw@dsiw-it.de"]
  spec.description   = %q{Manipulates your HOME environment variable.}
  spec.summary       = %q{Manipulates and restores your HOME environment variable for test suites.}
  spec.homepage      = "https://github.com/DSIW/fake_home"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('version')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('yard')
end
