# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'refile/postgres/version'

Gem::Specification.new do |spec|
  spec.name          = "refile-postgres"
  spec.version       = Refile::Postgres::VERSION
  spec.authors       = ["Krists Ozols"]
  spec.email         = ["krists.ozols@gmail.com"]
  spec.summary       = %q{Postgres database as a backend for Refile}
  spec.description   = %q{Postgres database as a backend for Refile. Uses "Large Objects". See http://www.postgresql.org/docs/9.3/static/largeobjects.html for more info.}
  spec.homepage      = "https://github.com/krists/refile-postgres"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "refile", "~> 0.6.1"
  spec.add_dependency "pg"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "rails", "~> 4.2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "codeclimate-test-reporter"
end
