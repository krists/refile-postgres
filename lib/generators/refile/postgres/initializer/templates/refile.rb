require "refile"
Refile.configure do |config|
  config.store = Refile::Postgres::Backend.new(proc { ActiveRecord::Base.connection.raw_connection } )
end
