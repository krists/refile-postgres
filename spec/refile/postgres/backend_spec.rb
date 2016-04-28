require "spec_helper"
require "tempfile"

describe Refile::Postgres::Backend do
  let(:connection) { test_connection }
  let(:backend) { Refile::Postgres::Backend.new(connection_or_proc, max_size: 100) }

  context "Connection tests" do
    context "when not using procs and providing PG::Connection directly" do
      let(:connection_or_proc) { connection }
      it "reuses the same PG::Connection" do
        expect(backend.with_connection { |c| c.db }).to eq(TEST_DB_NAME)
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
          expect(backend.with_connection { |c| c.db }).to eq(TEST_DB_NAME)
        end
      end
    end
  end

  describe "#registry_table" do
    context "when no registry table is present" do
      it "raises an exception" do
        drop_registry_table
        expect {
          Refile::Postgres::Backend.new(test_connection, max_size: 100).registry_table
        }.to raise_error Refile::Postgres::Backend::RegistryTableDoesNotExistError
      end
    end

    context "when registry tables exist in multiple schemas" do
      before do
        test_connection.exec %{
          CREATE SCHEMA other_schema;
          CREATE TABLE IF NOT EXISTS other_schema.#{Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE}
          ( id serial NOT NULL );
        }
      end

      after do
        test_connection.exec %{
          DROP SCHEMA other_schema CASCADE;
        }
      end

      it "does not raise an exception" do
        expect {
          Refile::Postgres::Backend.new(test_connection, max_size: 100).registry_table
        }.not_to raise_error
      end
    end
  end

  describe "Orphaned large object cleaning" do
    let(:connection_or_proc) { test_connection }
    let(:backend) { Refile::Postgres::Backend.new(connection_or_proc, max_size: 10000 ) }
    it "does not garbage collect attachments after vacuumlo call" do
      uploadable = File.open(File.expand_path(__FILE__))
      file = backend.upload(uploadable)
      expect(backend.exists?(file.id)).to eq(true)
      run_vacuumlo
      expect(backend.exists?(file.id)).to eq(true)
    end
  end

  context "Refile Provided tests" do
    let(:connection_or_proc) { connection }
    it_behaves_like :backend
  end

  describe "Content streaming" do
    let(:connection_or_proc) { test_connection }
    let(:backend) { Refile::Postgres::Backend.new(connection_or_proc, max_size: 1000000 ) }
    it "allows to steam large file" do
      expect(Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE).to eq(16384)
      uploadable = Tempfile.new("test-file")
      uploadable.write "A" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE
      uploadable.write "B" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE
      uploadable.write "C" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE
      uploadable.close
      uploadable.open
      file = backend.upload(uploadable)
      expect(backend.exists?(file.id)).to eq(true)
      reader = backend.open(file.id)
      enum = reader.each
      expect(enum.next).to eq("A" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE)
      expect(enum.next).to eq("B" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE)
      expect(enum.next).to eq("C" * Refile::Postgres::Backend::Reader::STREAM_CHUNK_SIZE)
      expect { enum.next }.to raise_error(StopIteration)
    end

    it "allows to steam small file" do
      uploadable = Tempfile.new("test-file")
      uploadable.write "QWERTY"
      uploadable.close
      uploadable.open
      file = backend.upload(uploadable)
      expect(backend.exists?(file.id)).to eq(true)
      reader = backend.open(file.id)
      enum = reader.each
      expect(enum.next).to eq("QWERTY")
      expect { enum.next }.to raise_error(StopIteration)
    end
  end
end
