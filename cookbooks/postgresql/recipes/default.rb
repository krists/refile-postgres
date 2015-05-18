apt_repository 'postgresql' do
  uri          'http://apt.postgresql.org/pub/repos/apt/'
  distribution 'trusty-pgdg'
  components   ['main']
  key          'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  action :add
end

%w{
  postgresql-9.4
  postgresql-client-9.4
  postgresql-contrib-9.4
  postgresql-server-dev-9.4
}.each do |p|
  package p do
    action :install
  end
end

execute 'Create vagrant postgresql user' do
  guard = <<-EOH
    psql -U postgres -c "select * from pg_user where
    usename='vagrant'" |
    grep -c vagrant
  EOH
  user 'postgres'
  command %{psql -U postgres -c "CREATE ROLE vagrant PASSWORD 'vagrant' SUPERUSER CREATEDB LOGIN;"}
  not_if guard, user: 'postgres'
end
