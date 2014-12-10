require "refile"
Refile.configure do |config|
  config.store = Refile::Postgres::Backend.new(ActiveRecord::Base.connection.raw_connection)
end
