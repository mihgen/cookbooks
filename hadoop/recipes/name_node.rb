if node[:hadoop][:ha][:status] == "enabled"
  node[:hadoop][:hdfs_name] = "#{node[:glusterfs][:mount_dir]}/hdfs/name" 
else
  node[:hadoop][:hdfs_name] = node[:hadoop][:hdfs_name_default]
end
log "hdfs_name home set to #{node[:hadoop][:hdfs_name]}"


directory node[:hadoop][:hdfs_name] do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  recursive true
end

%w{ namenode-start.sh namenode-stop.sh namenode-clean.sh }.each do |file|
  template "#{node[:hadoop][:userhome]}/#{file}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    source "#{file}.erb"
  end
end

include_recipe "hadoop"
