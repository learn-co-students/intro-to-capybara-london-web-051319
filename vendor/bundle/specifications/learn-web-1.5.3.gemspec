# -*- encoding: utf-8 -*-
# stub: learn-web 1.5.3 ruby lib

Gem::Specification.new do |s|
  s.name = "learn-web".freeze
  s.version = "1.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Flatiron School".freeze]
  s.date = "2018-08-24"
  s.email = ["learn@flatironschool.com".freeze]
  s.homepage = "https://learn.co".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "An interface to Learn.co".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.11.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.7.0"])
      s.add_runtime_dependency(%q<faraday>.freeze, ["~> 0.9"])
      s.add_runtime_dependency(%q<oj>.freeze, ["~> 2.9"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.11.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7.0"])
      s.add_dependency(%q<faraday>.freeze, ["~> 0.9"])
      s.add_dependency(%q<oj>.freeze, ["~> 2.9"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.11.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7.0"])
    s.add_dependency(%q<faraday>.freeze, ["~> 0.9"])
    s.add_dependency(%q<oj>.freeze, ["~> 2.9"])
  end
end
