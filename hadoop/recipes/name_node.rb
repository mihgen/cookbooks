include_recipe "hadoop"

%w{ namenode-start.sh namenode-stop.sh namenode-clean.sh }.each do |file|
  template "#{node[:hadoop][:userhome]}/#{file}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    source "#{file}.erb"
    variables({
      :hdfs_name_dir => node[:hadoop][:hdfs_name_dir],
      :hdfs_data_dir => node[:hadoop][:hdfs_data_dir]
    })
  end
end

