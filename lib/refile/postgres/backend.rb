module Refile
  module Postgres
    class Backend
      include SmartTransaction
      extend Refile::BackendMacros
      RegistryTableDoesNotExistError = Class.new(StandardError)
      DEFAULT_REGISTRY_TABLE = "refile_attachments"
      DEFAULT_NAMESPACE = "default"
      PG_LARGE_OBJECT_TABLE = "pg_largeobject"
      READ_CHUNK_SIZE = 3000

      def initialize(connection, max_size: nil, namespace: DEFAULT_NAMESPACE, registry_table: DEFAULT_REGISTRY_TABLE)
        unless connection.is_a?(PG::Connection)
          raise ArgumentError.new("First argument should be an instance of PG::Connection. When using ActiveRecord it is available as ActiveRecord::Base.connection.raw_connection")
        end
        @connection = connection
        @namespace = namespace.to_s
        @registry_table = registry_table
        @registry_table_validated = false
        @max_size = max_size
      end

      attr_reader :connection, :namespace, :max_size

      def registry_table
        unless @registry_table_validated
          connection.exec %{
            SELECT count(*) from pg_catalog.pg_tables
            WHERE tablename = '#{@registry_table}';
          } do |result|
            unless result[0]["count"].to_i > 0
              raise RegistryTableDoesNotExistError.new(%{Please create a table "#{@registry_table}" where backend could store list of attachments})
            end
          end
          @registry_table_validated = true
        end
        @registry_table
      end

      verify_uploadable def upload(uploadable)
        # Refile.verify_uploadable(uploadable, max_size)
        oid = connection.lo_creat
        ensure_in_transaction do
          begin
            handle = connection.lo_open(oid, PG::INV_WRITE)
            connection.lo_truncate(handle, 0)
            buffer = "" # reuse the same buffer
            until uploadable.eof?
              uploadable.read(READ_CHUNK_SIZE, buffer)
              connection.lo_write(handle, buffer)
            end
            uploadable.close
            connection.exec_params("INSERT INTO #{registry_table} VALUES ($1::integer, $2::varchar);", [oid, namespace])
            Refile::File.new(self, oid.to_s)
          ensure
            connection.lo_close(handle)
          end
        end
      end

      verify_id def open(id)
        if exists?(id)
          Reader.new(connection, id)
        else
          raise ArgumentError.new("No such attachment with ID: #{id}")
        end
      end

      verify_id def read(id)
        if exists?(id)
          open(id).read
        else
          nil
        end
      end

      verify_id def get(id)
        Refile::File.new(self, id)
      end

      verify_id def exists?(id)
        connection.exec_params(%{
          SELECT count(*) FROM #{registry_table}
          INNER JOIN #{PG_LARGE_OBJECT_TABLE}
          ON #{registry_table}.id = #{PG_LARGE_OBJECT_TABLE}.loid
          WHERE #{registry_table}.namespace = $1::varchar
          AND #{registry_table}.id = $2::integer;
        }, [namespace, id.to_s.to_i]) do |result|
          result[0]["count"].to_i > 0
        end
      end

      verify_id def size(id)
        if exists?(id)
          open(id).size
        else
          nil
        end
      end

      verify_id def delete(id)
        if exists?(id)
          ensure_in_transaction do
            connection.lo_unlink(id.to_s.to_i)
            connection.exec_params("DELETE FROM #{registry_table} WHERE id = $1::integer;", [id])
          end
        end
      end

      def clear!(confirm = nil)
        raise Refile::Confirm unless confirm == :confirm
        registry_table
        ensure_in_transaction do
          connection.exec_params(%{
            SELECT * FROM #{registry_table}
            INNER JOIN #{PG_LARGE_OBJECT_TABLE} ON #{registry_table}.id = #{PG_LARGE_OBJECT_TABLE}.loid
            WHERE #{registry_table}.namespace = $1::varchar;
          }, [namespace]) do |result|
            result.each_row do |row|
              connection.lo_unlink(row[0].to_s.to_i)
            end
          end
          connection.exec_params("DELETE FROM #{registry_table} WHERE namespace = $1::varchar;", [namespace])
        end
      end
    end
  end
end

