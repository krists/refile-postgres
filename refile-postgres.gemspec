require_relative "./lib/refile/postgres/version"

Gem::Specification.new do |spec|
  spec.name          = "refile-postgres"
  spec.version       = Refile::Postgres::VERSION
  spec.authors       = ["Krists Ozols"]
  spec.email         = ["krists.ozols@gmail.com"]
  spec.summary       = %q{Postgres database as a backend for Refile}
  spec.description   = %q{Postgres database as a backend for Refile. Uses "Large Objects". See https://www.postgresql.org/docs/current/largeobjects.html for more info.}
  spec.homepage      = "https://github.com/krists/refile-postgres"
  spec.license       = "MIT"
  spec.files         = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.add_dependency "refile", [">= 0.6", "< 0.8"]
  spec.add_dependency "pg"
end
