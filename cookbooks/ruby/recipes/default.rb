
remote_file "/tmp/ruby-install-#{node[:ruby_install][:version]}.tar.gz" do
  source "https://github.com/postmodern/ruby-install/archive/v#{node[:ruby_install][:version]}.tar.gz"
  action :create
end

bash "Extract ruby-install source code" do
  code <<-EOH
    cd /tmp
    tar -zxvf ruby-install-#{node[:ruby_install][:version]}.tar.gz
  EOH
  not_if { ::File.exists?("/tmp/ruby-install-#{node[:ruby_install][:version]}") }
end

execute 'Install ruby-install' do
  cwd "/tmp/ruby-install-#{node[:ruby_install][:version]}"
  command 'make install'
  action :run
  not_if { ::File.exists?("/usr/local/bin/ruby-install") }
end

remote_file "/tmp/chruby-#{node[:chruby][:version]}.tar.gz" do
  source "https://github.com/postmodern/chruby/archive/v#{node[:chruby][:version]}.tar.gz"
  action :create
end

bash "Extract chruby source code" do
  code <<-EOH
    cd /tmp
    tar -zxvf chruby-#{node[:chruby][:version]}.tar.gz
  EOH
  not_if { ::File.exists?("/tmp/chruby-#{node[:chruby][:version]}") }
end

execute 'Install chruby' do
  cwd "/tmp/chruby-#{node[:chruby][:version]}"
  command 'make install'
  action :run
  not_if { ::File.exists?("/usr/local/bin/chruby") }
end

file "/etc/profile.d/chruby.sh" do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOC
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
      source /usr/local/share/chruby/chruby.sh
      source /usr/local/share/chruby/auto.sh
    fi
  EOC
end
