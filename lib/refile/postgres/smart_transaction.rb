module Refile
  module Postgres
    module SmartTransaction

      PQTRANS_INTRANS = 2 # (idle, within transaction block)

      def smart_transaction
        result = nil
        ensure_in_transaction do
          begin
            handle = connection.lo_open(oid)
            result = yield handle
            connection.lo_close(handle)
          end
        end
        result
      end

      def ensure_in_transaction
        if connection.transaction_status == PQTRANS_INTRANS
          yield
        else
          connection.transaction do
            yield
          end
        end
      end

    end
  end
end
