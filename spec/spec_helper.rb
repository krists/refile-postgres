require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(Gem::Specification.find_by_name("refile").gem_dir, "spec"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "refile/spec_helper"
require "pg"
require "pry"
require "refile/postgres"

WebMock.disable!(:except => [:codeclimate_test_reporter])

RSpec.configure do |config|
  config.before(:all) do
    connection = PG.connect(host: 'localhost', dbname: 'refile_test', user: 'refile_postgres_test_user', password: 'refilepostgres')
    connection.exec %{ DROP TABLE IF EXISTS #{Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE} CASCADE; }
    connection.exec %{
      CREATE TABLE IF NOT EXISTS #{Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE}
      (
        id serial NOT NULL,
        namespace character varying(255),
        CONSTRAINT refile_backend_lo_oids_pkey PRIMARY KEY (id)
      )
      WITH(
        OIDS=FALSE
      );
    }
  end
end
