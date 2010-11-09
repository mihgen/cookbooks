
%w{ name_node data_node }.each do |daemon|
  start_daemons daemon do
    command "rm -rf #{node[:hadoop][:hdfs_name]}; rm -rf #{node[:hadoop][:hdfs_data]}"
  end
end
