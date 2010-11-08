# secondary_name_node job_tracker task_tracker zookeeper hbase_master region_server

%w{ name_node data_node }.each do |daemon|
  start_daemons daemon do
    command node[:hadoop][daemon.to_sym][:start_cmd]
  end
end

