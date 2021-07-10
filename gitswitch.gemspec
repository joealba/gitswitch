# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gitswitch/version"

Gem::Specification.new do |s|
  s.name = %q{gitswitch}
  s.version = Gitswitch::VERSION
  s.platform = Gem::Platform::RUBY

  s.authors = ["Joe Alba"]
  s.date = %q{2012-04-29}
  s.homepage = %q{https://github.com/joealba/gitswitch}
  s.description = %q{Easily switch your git name/e-mail user info -- Handy for work vs. personal and for pair programming}
  s.summary = %q{Easy git user switching}
  s.email = %q{joe@joealba.com}
  s.metadata = {
    "bug_tracker_uri" => "#{s.homepage}/issues",
    "changelog_uri" => "#{s.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => s.homepage.to_s,
    "homepage_uri" => s.homepage.to_s,
    "source_code_uri" => s.homepage.to_s
  }

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('rake')
  s.add_dependency('dry-cli')
  s.add_dependency('tty-prompt')
  s.add_development_dependency(%q<rspec>, [">= 3.3.0"])
  s.add_development_dependency 'simplecov'
end
