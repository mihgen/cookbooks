unless node[:hadoop][:ha].nil? 
  node[:hadoop][:hdfs_name] = "#{node[:glusterfs][:mount_dir]}/hdfs/name" 
else
  node[:hadoop][:hdfs_name] = node[:hadoop][:hdfs_name_default]
end
log "hdfs_name home set to #{node[:hadoop][:hdfs_name]}"

include_recipe "hadoop"

directory node[:hadoop][:hdfs_name] do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  recursive true
end
unless node[:hadoop][:ha].nil?
  name_node_fqdn = [ node[:hadoop][:ha][:fqdn] ]
else
  name_node_fqdn = search(:node, %Q{run_list:"recipe[hadoop::name_node]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
end
log "Set NameNode to: #{name_node_fqdn} from recipe name_node."

template "#{node[:hadoop][:scripts_dir]}/name_node.sh" do
  source "scripts.sh.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => "namenode",
    :hosts => name_node_fqdn
  })
end

%w{ namenode-start.sh namenode-stop.sh namenode-clean.sh }.each do |file|
  template "#{node[:hadoop][:userhome]}/#{file}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    source "#{file}.erb"
    variables({
      :dir => node[:hadoop][:hdfs_name],
      :host => name_node_fqdn
    })
  end
end

