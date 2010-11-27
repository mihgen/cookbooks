include_recipe "hadoop"

hosts = search(:node, %Q{run_list:"recipe[hadoop::secondary_name_node]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found SecondaryNameNode hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/secondary_name_node.sh" do
  source "scripts.sh.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => "secondarynamenode",
    :hosts => hosts 
  })
end
