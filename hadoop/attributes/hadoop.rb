#ntp Mash.new unless attribute?("hadoop")

hadoop Mash.new
hbase Mash.new

set.hadoop.user = "hadoop"
set.hadoop.userhome = "/hadoop"
set.hadoop.download_url = "http://www.sai.msu.su/apache/hadoop/core/hadoop-0.20.2/hadoop-0.20.2.tar.gz"
set.hadoop.core_dir = "#{node[:hadoop][:userhome]}/core"
set.hadoop.conf_dir = "#{node[:hadoop][:core_dir]}/conf"
set.hadoop.hdfs_name = "#{node[:hadoop][:userhome]}/hdfs/name"
set.hadoop.hdfs_data = "#{node[:hadoop][:userhome]}/hdfs/data"

# HBASE settings
set.hbase.user = "hadoop"
set.hbase.userhome = "/hadoop"
set.hbase.download_url = "http://archive.apache.org/dist/hadoop/hbase/hbase-0.20.2/hbase-0.20.2.tar.gz"
set.hbase.core_dir = "#{node[:hbase][:userhome]}/hbase"
set.hbase.conf_dir = "#{node[:hbase][:core_dir]}/conf"

# Zookeeper settings
set.hadoop.zookeeper.data_dir = "#{node[:hadoop][:userhome]}/zookeeper/data"

# Remote commands to start daemons:
hadoop_setvar = "cd #{node[:hadoop][:core_dir]}/bin; export JAVA_HOME=#{node[:java][:home]}; export HADOOP_HOME=#{node[:hadoop][:core_dir]}"
hadoop_precmd = "#{hadoop_setvar}; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]}" 
hbase_setvar = "cd #{node[:hbase][:core_dir]}/bin; export JAVA_HOME=#{node[:java][:home]}; export HBASE_HOME=#{node[:hbase][:core_dir]}"
hbase_precmd = "#{hbase_setvar}; ./hbase-daemon.sh --config #{node[:hbase][:conf_dir]}"

set.hadoop.daemons.name_node.start_cmd = "#{hadoop_precmd}; start namenode"
set.hadoop.daemons.name_node.stop_cmd = "#{hadoop_precmd} stop namenode"
set.hadoop.daemons.name_node.clean_cmd = "#{hadoop_setvar}; rm -rf #{node[:hadoop][:hdfs_name]}/*; echo Y | #{node[:hadoop][:core_dir]}/bin/hadoop namenode -format"

set.hadoop.daemons.data_node.start_cmd = "#{hadoop_precmd} start datanode"
set.hadoop.daemons.data_node.stop_cmd = "#{hadoop_precmd} stop datanode"
set.hadoop.daemons.name_node.clean_cmd = "#{hadoop_setvar}; rm -rf #{node[:hadoop][:hdfs_data]}/*; echo Y | #{node[:hadoop][:core_dir]}/bin/hadoop namenode -format"

set.hadoop.daemons.secondary_name_node.start_cmd = "#{hadoop_precmd} start secondarynamenode"
set.hadoop.daemons.secondary_name_node.stop_cmd = "#{hadoop_precmd} stop secondarynamenode"

set.hadoop.daemons.job_tracker.start_cmd = "#{hadoop_precmd} start jobtracker"
set.hadoop.daemons.job_tracker.stop_cmd = "#{hadoop_precmd} stop jobtracker"

set.hadoop.daemons.task_tracker.start_cmd = "#{hadoop_precmd} start tasktracker"
set.hadoop.daemons.task_tracker.stop_cmd = "#{hadoop_precmd} stop tasktracker"

set.hadoop.daemons.zookeeper.start_cmd = "#{hbase_precmd} start zookeeper"
set.hadoop.daemons.zookeeper.stop_cmd = "#{hbase_precmd} stop zookeeper"

set.hadoop.daemons.hbase_master.start_cmd = "#{hbase_precmd} start master"
set.hadoop.daemons.hbase_master.stop_cmd = "#{hbase_precmd} stop master"

set.hadoop.daemons.region_server.start_cmd = "#{hbase_precmd} start regionserver"
set.hadoop.daemons.region_server.stop_cmd = "#{hbase_precmd} stop regionserver"

#ntp[:servers] = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"] unless ntp.has_key?(:servers)
