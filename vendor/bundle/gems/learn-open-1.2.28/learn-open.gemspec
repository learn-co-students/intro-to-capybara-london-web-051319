# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_open/version'

Gem::Specification.new do |spec|
  spec.name          = "learn-open"
  spec.version       = LearnOpen::VERSION
  spec.authors       = ["Flatiron School"]
  spec.email         = ["learn@flatironschool.com"]
  spec.summary       = %q{Open Learn lessons locally}
  spec.homepage      = "https://github.com/learn-co/learn-open"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "bin"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "fakefs",  "~> 0.14.2"
  spec.add_development_dependency "pry",     "~> 0.11.1"
  spec.add_development_dependency "rspec-core","~> 3.7.1"
  spec.add_development_dependency "rspec-mocks","~> 3.7.0"
  spec.add_development_dependency "diff-lcs", "~> 1.3"
  spec.add_development_dependency "guard-rspec", "~> 4.7.0"

  spec.add_runtime_dependency "netrc"
  spec.add_runtime_dependency "git"
  spec.add_runtime_dependency "learn-web", ">= 1.5.2"
end
