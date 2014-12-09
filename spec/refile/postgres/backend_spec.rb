require "spec_helper"

RSpec.describe Refile::Postgres::Backend do
  let(:db_connection) { PG.connect(dbname: 'refile_test') }
  let(:backend) { Refile::Postgres::Backend.new(db_connection, max_size: 100) }
  it_behaves_like :backend
end

