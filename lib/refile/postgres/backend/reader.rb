module Refile
  module Postgres
    class Backend
      class Reader
        include SmartTransaction

        def initialize(connection_or_proc, oid)
          @connection_or_proc = connection_or_proc
          @oid = oid.to_s.to_i
          @closed = false
          @pos = 0
        end

        attr_reader :oid, :pos

        def read(length = nil, buffer = nil)
          result = if length
            raise "closed" if @closed
            with_connection do |connection|
              smart_transaction(connection) do |descriptor|
                connection.lo_lseek(descriptor, @pos, PG::SEEK_SET)
                data = connection.lo_read(descriptor, length)
                @pos = connection.lo_tell(descriptor)
                data
              end
            end
          else
            with_connection do |connection|
              smart_transaction(connection) do |descriptor|
                connection.lo_read(descriptor, size)
              end
            end
          end
          buffer.replace(result) if buffer and result
          result
        end

        def eof?
          with_connection do |connection|
            smart_transaction(connection) do |descriptor|
              @pos == size
            end
          end
        end

        def size
          @size ||= fetch_size
        end

        def close
          @closed = true
        end

        private

        def fetch_size
          with_connection do |connection|
            smart_transaction(connection) do |descriptor|
              current_position = connection.lo_tell(descriptor)
              end_position = connection.lo_lseek(descriptor, 0, PG::SEEK_END)
              connection.lo_lseek(descriptor, current_position, PG::SEEK_SET)
              end_position
            end
          end
        end

      end
    end
  end
end


