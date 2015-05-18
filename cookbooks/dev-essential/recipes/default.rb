include_recipe "locale"

%w{
  git-core curl vim tmux
}.each do |p|
  package p do
    action :install
  end
end
