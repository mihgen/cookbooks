include_recipe "hadoop::hbase"

hosts = search(:node, %Q{run_list:"recipe[hadoop::hbase_master]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found hbase master hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/hbase_master.sh" do
  source "scripts.sh.erb"
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hbase",
    :service => "master",
    :hosts => hosts 
  })
end
