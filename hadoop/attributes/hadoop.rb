#ntp Mash.new unless attribute?("hadoop")

hadoop Mash.new
hbase Mash.new

set.hadoop.env_id = "ras-qa"

set.hadoop.user = "hadoop"
set.hadoop.userhome = "/hadoop"
set.hadoop.download_url = "http://www.sai.msu.su/apache/hadoop/core/hadoop-0.20.2/hadoop-0.20.2.tar.gz"
set.hadoop.core_dir = "#{node[:hadoop][:userhome]}/core"
set.hadoop.scripts_dir = "#{node[:hadoop][:userhome]}/scripts"
set.hadoop.conf_dir = "#{node[:hadoop][:core_dir]}/conf"
set.hadoop.hdfs_name_default = "#{node[:hadoop][:userhome]}/hdfs/name"   # For HA another dir is used, see name_node recipe.
set.hadoop.hdfs_data = "#{node[:hadoop][:userhome]}/hdfs/data"

# HA Hadoop settings. Comment all of them to disable.
set.hadoop.ha.status = "enabled"
set.hadoop.ha.fqdn = "ras-namenode2.vm.griddynamics.net"
set.hadoop.ha.ip = "172.16.68.25"
set.hadoop.ha.subnet = "23"
set.hadoop.ha.broadcast = "172.16.69.255"
set.hadoop.ha.interface = "eth0"
set.hadoop.ha.keepalived_pass = "jsk_92KWBAajd@dk"
set.hadoop.ha.master.namenode_weight = "10"
set.hadoop.ha.master.gluster_ser_weight = "5"
set.hadoop.ha.master.gluster_cli_weight = "20"
set.hadoop.ha.master.priority = "100"
set.hadoop.ha.backup.namenode_weight = "5"
set.hadoop.ha.backup.gluster_ser_weight = "10"
set.hadoop.ha.backup.gluster_cli_weight = "20"
set.hadoop.ha.backup.priority = "99"

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

#set.hadoop.daemons_in_order = %w{ name_node data_node secondary_name_node job_tracker task_tracker zookeeper hbase_master region_server }
# For HA setup:
set.hadoop.daemons_in_order = %w{ name_node_master data_node secondary_name_node job_tracker task_tracker zookeeper hbase_master region_server }
set.hadoop.daemons.name_node = "namenode"
set.hadoop.daemons.name_node_master = "namenode"
set.hadoop.daemons.data_node = "datanode"
set.hadoop.daemons.secondary_name_node = "secondarynamenode"
set.hadoop.daemons.job_tracker = "jobtracker"
set.hadoop.daemons.task_tracker = "tasktracker"
set.hadoop.daemons.zookeeper = "zookeeper"
set.hadoop.daemons.hbase_master = "master"
set.hadoop.daemons.region_server = "region_server"

