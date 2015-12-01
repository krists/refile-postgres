require "refile"
Refile.configure do |config|
  connection = lambda { |&blk| ActiveRecord::Base.connection_pool.with_connection { |con| blk.call(con.raw_connection) } }
  config.store = Refile::Postgres::Backend.new(connection)
end
