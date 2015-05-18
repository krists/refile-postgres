require "spec_helper"

RSpec.describe Refile::Postgres::Backend do
  let(:connection_or_proc) { PG.connect(dbname: 'refile_test') }
  let(:backend) { Refile::Postgres::Backend.new(connection_or_proc, max_size: 100) }
  it_behaves_like :backend

  context "Connection tests" do
    def connection
      PG.connect(dbname: 'refile_test')
    end

    context "when using proc" do
      def connection_or_proc
        proc { connection }
      end

      it "reuses the same PG::Connection if connection is ok" do
        expect(backend.connection).to eq(backend.connection)
      end

      it "executes proc and obtains new connection if old one is closed" do
        old = backend.connection
        old.close
        expect(backend.connection).not_to eq(old)
        expect(backend.connection.finished?).to be_falsey
      end
    end

    context "when not using procs and providing PG::Connection directly" do
      def connection_or_proc
        connection
      end

      it "reuses the same PG::Connection" do
        expect(backend.connection).to eq(backend.connection)
      end

      it "continues to use old connection if the old one is closed" do
        old = backend.connection
        old.close
        expect(backend.connection).to eq(old)
        expect(backend.connection.finished?).to be_truthy
      end
    end
  end
end
