require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(Gem::Specification.find_by_name("refile").gem_dir, "spec"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "refile/spec_helper"
require "pg"
require "pry"
require "refile/postgres"

WebMock.disable!(:except => [:codeclimate_test_reporter])

TEST_DB_NAME = ENV.fetch('POSTGRES_DB', 'refile_test')

module DatabaseHelpers
  def test_connection
    @@connection ||= PG.connect(host: ENV.fetch('POSTGRES_HOST','localhost'), dbname: ENV.fetch('POSTGRES_DB', TEST_DB_NAME), user: ENV.fetch('POSTGRES_USER','refile_postgres_test_user'), password: ENV.fetch('POSTGRES_PASSWORD','refilepostgres'))
  end

  def create_registy_table
    test_connection.exec %{
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

  def drop_registry_table
    test_connection.exec %{ DROP TABLE IF EXISTS #{Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE} CASCADE; }
  end
end

RSpec.configure do |config|
  config.include DatabaseHelpers

  config.around(:each) do |example|
    create_registy_table
    example.run
    drop_registry_table
  end
end
