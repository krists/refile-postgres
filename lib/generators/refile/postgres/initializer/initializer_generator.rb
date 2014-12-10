class Refile::Postgres::InitializerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  def copy_initializer_file
    copy_file "refile.rb", "config/initializers/refile.rb"
  end
end
