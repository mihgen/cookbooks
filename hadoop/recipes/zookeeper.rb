include_recipe "hadoop::hbase"

directory node[:hadoop][:zookeeper][:data_dir] do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  recursive true
end

zookeeper_hosts = search(:node, %q{run_list:"recipe[hadoop::zookeeper]"}).map{ |e| e["fqdn"] }
zookeeper_id = zookeeper_hosts.index(node[:fqdn])

template "#{node[:hadoop][:zookeeper][:data_dir]}/myid" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "myid.erb"
  variables({
    :zookeeper_id => zookeeper_id
  })
end
