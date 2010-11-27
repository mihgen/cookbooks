include_recipe "keepalived"
include_recipe "glusterfs"
include_recipe "hadoop::keepalived"
include_recipe "hadoop::name_node"

service "keepalived" do
  action :nothing
end

template node[:keepalived][:config] do
  mode 0600
  source "keepalived.conf.erb"
  variables({
    :weights => node[:hadoop][:ha][:master]
  })
  notifies :restart, resources(:service => "keepalived")
end

hosts = search(:node, %Q{run_list:"recipe[hadoop::name_node_master]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found Master NameNode hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/name_node.sh" do
  source "scripts.sh.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => "namenode",
    :hosts => hosts 
  })
end
