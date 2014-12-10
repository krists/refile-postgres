module Refile
  module Postgres
    class Backend
      class Reader
        include SmartTransaction

        def initialize(connection, oid)
          @connection = connection
          @oid = oid.to_s.to_i
          @closed = false
          @pos = 0
        end

        attr_reader :connection, :oid, :pos

        def read(length = nil, buffer = nil)
          result = if length
            raise "closed" if @closed
            smart_transaction do |descriptor|
              connection.lo_lseek(descriptor, @pos, PG::SEEK_SET)
              data = connection.lo_read(descriptor, length)
              @pos = connection.lo_tell(descriptor)
              data
            end
          else
            smart_transaction do |descriptor|
              connection.lo_read(descriptor, size)
            end
          end
          buffer.replace(result) if buffer and result
          result
        end

        def eof?
          smart_transaction do |descriptor|
            @pos == size
          end
        end

        def size
          @size ||= smart_transaction do |descriptor|
            current_position = connection.lo_tell(descriptor)
            end_position = connection.lo_lseek(descriptor, 0, PG::SEEK_END)
            connection.lo_lseek(descriptor, current_position, PG::SEEK_SET)
            end_position
          end
        end

        def close
          @closed = true
        end

      end
    end
  end
end


