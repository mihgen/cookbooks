include_recipe "hadoop"

hosts = search(:node, %Q{run_list:"recipe[hadoop::data_node]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found DataNode hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/data_node.sh" do
  source "scripts.sh.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => "datanode",
    :hosts => hosts 
  })
end
