# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_annotator/version'

Gem::Specification.new do |spec|
  spec.name          = "db-annotator"
  spec.version       = DbAnnotator::VERSION
  spec.authors       = ["Mavenlink, Inc."]
  spec.email         = ["oss@mavenlink.com"]

  spec.summary       = %q{Adds query annotation support to ActiveRecord connection adapters.}
  # spec.description   = %q{TODO}
  spec.homepage      = "https://github.com/mavenlink/db-annotator"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.0.0'

  spec.files = `git ls-files README.md CHANGELOG.md CODE_OF_CONDUCT.md LICENSE lib`.split
  spec.test_files = `git ls-files spec`.split

  spec.add_dependency "mysql2", ">= 0.4"

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "db-query-matchers"
  spec.add_development_dependency "activerecord", "~> 5.0"
  spec.add_development_dependency "pry"
end
