module Refile
  module Postgres
    module SmartTransaction
      INIT_CONNECTION_ARG_ERROR_MSG = "When initializing new Refile::Postgres::Backend first argument should be an instance of PG::Connection or a lambda/proc that yields it."
      PQTRANS_INTRANS = 2 # (idle, within transaction block)

      def smart_transaction(connection)
        result = nil
        ensure_in_transaction(connection) do
          begin
            handle = connection.lo_open(oid)
            result = yield handle
            connection.lo_close(handle)
          end
        end
        result
      end

      def ensure_in_transaction(connection)
        if connection.transaction_status == PQTRANS_INTRANS
          yield
        else
          connection.transaction do
            yield
          end
        end
      end

      def with_connection
        if @connection_or_proc.is_a?(PG::Connection)
          yield @connection_or_proc
        else
          if @connection_or_proc.is_a?(Proc)
            block_has_been_executed = false
            value = nil
            @connection_or_proc.call do |connection| 
              block_has_been_executed = true
              raise ArgumentError.new(INIT_CONNECTION_ARG_ERROR_MSG) unless connection.is_a?(PG::Connection)
              value = yield connection
            end
            raise ArgumentError.new(INIT_CONNECTION_ARG_ERROR_MSG) unless block_has_been_executed
            value
          else
            raise ArgumentError.new(INIT_CONNECTION_ARG_ERROR_MSG)
          end
        end
      end

    end
  end
end
