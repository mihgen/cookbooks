include_recipe "django"
include_recipe "git"

bash "install dashboard" do
  user "root"
  cwd "/usr/local"
  code %(git clone git://github.com/phunt/zookeeper_dashboard.git)
end

zk_servers = search(:node, "role:zookeeper")[0]

template "/usr/local/zookeeper_dashboard/settings.py" do
  source "settings.py.erb"
  mode 0644
  variables(:zk_servers => zk_servers)
end

runit_server "zookeeper_dashboard"
