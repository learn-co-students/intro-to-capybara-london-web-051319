# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_web/version'

Gem::Specification.new do |spec|
  spec.name          = "learn-web"
  spec.version       = LearnWeb::VERSION
  spec.authors       = ["Flatiron School"]
  spec.email         = ["learn@flatironschool.com"]
  spec.summary       = %q{An interface to Learn.co}
  spec.homepage      = "https://learn.co"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "rspec", "~> 3.8.0"
  spec.add_development_dependency "guard-rspec", "~> 4.7.0"

  spec.add_runtime_dependency "faraday", "~> 0.9"
  spec.add_runtime_dependency "oj", "~> 2.9"
end
