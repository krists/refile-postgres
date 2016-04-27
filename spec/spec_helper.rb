require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(Gem::Specification.find_by_name("refile").gem_dir, "spec"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "refile/spec_helper"
require "pg"
require "pry"
require "refile/postgres"
require "open3"

WebMock.disable!(:except => [:codeclimate_test_reporter])

TEST_DB_NAME = ENV.fetch('POSTGRES_DB', 'refile_test')
TEST_DB_HOST = ENV.fetch('POSTGRES_HOST','localhost')
TEST_DB_USER = ENV.fetch('POSTGRES_USER','refile_postgres_test_user')
TEST_DB_PASSWD = ENV.fetch('POSTGRES_PASSWORD','refilepostgres')
module DatabaseHelpers
  def test_connection
    @@connection ||= PG.connect(host: TEST_DB_HOST, dbname: TEST_DB_NAME, user: TEST_DB_USER, password: TEST_DB_PASSWD)
  end

  def create_registy_table(name = Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE)
    test_connection.exec %Q{
      DROP TABLE IF EXISTS #{name};
      CREATE TABLE #{name} (
      id integer NOT NULL,
      oid oid NOT NULL,
      namespace character varying NOT NULL,
      created_at timestamp without time zone DEFAULT ('now'::text)::timestamp without time zone
      );

      CREATE SEQUENCE #{name}_id_seq
      START WITH 1
      INCREMENT BY 1
      NO MINVALUE
      NO MAXVALUE
      CACHE 1;

      ALTER SEQUENCE #{name}_id_seq OWNED BY #{name}.id;

      ALTER TABLE ONLY #{name} ALTER COLUMN id SET DEFAULT nextval('#{name}_id_seq'::regclass);

      ALTER TABLE ONLY #{name} ADD CONSTRAINT #{name}_pkey PRIMARY KEY (id);

      CREATE INDEX index_#{name}_on_namespace ON #{name} USING btree (namespace);

      CREATE INDEX index_#{name}_on_oid ON #{name} USING btree (oid);
    }
  end

  def drop_registry_table(name = Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE)
    test_connection.exec %{ DROP TABLE IF EXISTS #{name} CASCADE; }
  end

  def run_vacuumlo
    command = "export PGPASSWORD=#{TEST_DB_PASSWD}; vacuumlo  -h #{TEST_DB_HOST} -U #{TEST_DB_USER} -w -v #{TEST_DB_NAME}"
    Open3.popen3(command) do |stdin, stdout, stderr, thread|
      stdin.close
      IO.copy_stream(stderr, $stderr)
      IO.copy_stream(stdout, $stdout)
    end
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
