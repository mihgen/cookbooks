include_recipe "hadoop::hbase"

hosts = search(:node, %Q{run_list:"recipe[hadoop::zookeeper]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found Zookeeper hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/zookeeper.sh" do
  source "scripts.sh.erb"
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hbase",
    :service => "zookeeper",
    :hosts => hosts 
  })
end
