include_recipe "hadoop"

hosts = search(:node, %Q{run_list:"recipe[hadoop::job_tracker]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found JobTracker hosts: #{hosts.join(',')}"

template "#{node[:hadoop][:scripts_dir]}/job_tracker.sh" do
  source "scripts.sh.erb"
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => "jobtracker",
    :hosts => hosts 
  })
end
