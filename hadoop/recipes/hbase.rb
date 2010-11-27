include_recipe "hadoop"

#user "#{node[:hbase][:user]}" do
  #home "#{node[:hbase][:userhome]}"
  #comment "hbase User"
#end

filename = node[:hbase][:download_url].scan(/\/([^\/]+)$/).to_s
log "filename: #{filename}"

log "Download URL: #{node[:hbase][:download_url]}"

remote_file "#{node[:hbase][:userhome]}/#{filename}" do
  owner node[:hbase][:user]
  backup false
  source "#{node[:hbase][:download_url]}"
  action :create
  not_if do File.exists?("#{node[:hbase][:userhome]}/#{filename}") end
end

unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s

script "install_hbase" do
  interpreter "bash"
  user "#{node[:hbase][:user]}"
  group "#{node[:hbase][:user]}"
  cwd "#{node[:hbase][:userhome]}"
  code <<-EOH 
  tar -kxzf #{filename}
  EOH
  not_if do File.exists?("#{node[:hbase][:userhome]}/#{unpack_dir}/conf") end
end

link node[:hbase][:core_dir] do
  to "#{node[:hbase][:userhome]}/#{unpack_dir}"
end

template "#{node[:hbase][:conf_dir]}/hbase-env.sh" do
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0644
  source "hbase-env.sh.erb"
end

unless node[:hadoop][:ha].nil?
  name_node_fqdn = node[:hadoop][:ha][:fqdn]
else
  name_node_fqdn = search(:node, %Q{run_list:"recipe[hadoop::name_node]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
end
log "Set NameNode host to: #{name_node_fqdn}"

directory node[:hadoop][:zookeeper][:data_dir] do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  recursive true
end

zookeeper_hosts = search(:node, %Q{run_list:"recipe[hadoop::zookeeper]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found zookeeper hosts: #{zookeeper_hosts.join(',')}"
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

template "#{node[:hbase][:conf_dir]}/hbase-site.xml" do
  source "hbase-site.xml.erb"
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0644
  variables({
    :zk_hosts => zookeeper_hosts,
    :namenode_host => name_node_fqdn
  })
end
