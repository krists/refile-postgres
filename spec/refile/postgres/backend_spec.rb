require "spec_helper"

describe Refile::Postgres::Backend do
  let(:connection) { PG.connect(dbname: 'refile_test') }
  let(:backend) { Refile::Postgres::Backend.new(connection_or_proc, max_size: 100) }

  context "Connection tests" do
    context "when not using procs and providing PG::Connection directly" do
      let(:connection_or_proc) { connection }
      it "reuses the same PG::Connection" do
        expect(backend.with_connection { |c| c.db }).to eq("refile_test")
      end
    end

    context "when using proc" do
      context "when lambda does not yield a block but returns connection" do
        let(:connection_or_proc) { lambda { connection } }
        it "raises argument error" do
          expect {
            backend.with_connection { |c| c.db }
          }.to raise_error(ArgumentError, "When initializing new Refile::Postgres::Backend first argument should be an instance of PG::Connection or a lambda/proc that yields it.")
        end
      end
      context "when lambda does yield a PG::Connection" do
        let(:connection_or_proc) { lambda { |&blk| blk.call(connection) } }
        it "is usable in queries" do
          expect(backend.with_connection { |c| c.db }).to eq("refile_test")
        end
      end
    end
  end

  context "Refile Provided tests" do
    let(:connection_or_proc) { connection }
    it_behaves_like :backend
  end
end
