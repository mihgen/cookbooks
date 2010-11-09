#ntp Mash.new unless attribute?("hadoop")

hadoop Mash.new
hbase Mash.new

set_unless.hadoop.user = "hadoop"
set_unless.hadoop.userhome = "/hadoop"
set_unless.hadoop.download_url = "http://www.sai.msu.su/apache/hadoop/core/hadoop-0.20.2/hadoop-0.20.2.tar.gz"
set_unless.hadoop.core_dir = "#{node[:hadoop][:userhome]}/core"
set_unless.hadoop.conf_dir = "#{node[:hadoop][:core_dir]}/conf"
set_unless.hadoop.hdfs_name = "#{node[:hadoop][:userhome]}/hdfs/name"
set_unless.hadoop.hdfs_data = "#{node[:hadoop][:userhome]}/hdfs/data"

# HBASE settings
set_unless.hbase.user = "hadoop"
set_unless.hbase.userhome = "/hadoop"
set_unless.hbase.download_url = "http://archive.apache.org/dist/hadoop/hbase/hbase-0.20.2/hbase-0.20.2.tar.gz"
set_unless.hbase.core_dir = "#{node[:hbase][:userhome]}/hbase"
set_unless.hbase.conf_dir = "#{node[:hbase][:core_dir]}/conf"

# Zookeeper settings
set_unless.hadoop.zookeeper.data_dir = "#{node[:hadoop][:userhome]}/zookeeper/data"

# Remote commands to start daemons:
hadoop_prestart = "cd #{node[:hadoop][:core_dir]}/bin; export JAVA_HOME=#{node[:java][:home]}; export HADOOP_HOME=#{node[:hadoop][:core_dir]}"
hbase_prestart = "cd #{node[:hbase][:core_dir]}/bin; export JAVA_HOME=#{node[:java][:home]}; export HBASE_HOME=#{node[:hbase][:core_dir]}"

set.hadoop.name_node.start_cmd = "#{hadoop_prestart}; echo Y | #{node[:hadoop][:core_dir]}/bin/hadoop namenode -format; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} start namenode"
set.hadoop.data_node.start_cmd = "#{hadoop_prestart}; echo Y | #{node[:hadoop][:core_dir]}/bin/hadoop namenode -format; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} start datanode"
set.hadoop.secondary_name_node.start_cmd = "#{hadoop_prestart}; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} start secondarynamenode"
set.hadoop.job_tracker.start_cmd = "#{hadoop_prestart}; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} start jobtracker"
set.hadoop.task_tracker.start_cmd = "#{hadoop_prestart}; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} start tasktracker"

set.hadoop.zookeeper.start_cmd = "#{hbase_prestart}; ./hbase-daemon.sh --config #{node[:hbase][:conf_dir]} start zookeeper"
set.hadoop.hbase_master.start_cmd = "#{hbase_prestart}; ./hbase-daemon.sh --config #{node[:hbase][:conf_dir]} start master"
set.hadoop.region_server.start_cmd = "#{hbase_prestart}; ./hbase-daemon.sh --config #{node[:hbase][:conf_dir]} start regionserver"

#ntp[:servers] = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"] unless ntp.has_key?(:servers)
