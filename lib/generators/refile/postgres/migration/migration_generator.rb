require "refile"
require 'rails/generators/active_record'
class Refile::Postgres::MigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  argument :table_name, type: :string, default: Refile::Postgres::Backend::DEFAULT_REGISTRY_TABLE
  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def copy_migration_file
    migration_template "migration.rb.erb", "db/migrate/create_#{table_name}.rb"
  end
end
