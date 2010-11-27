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
set.hadoop.hdfs_name_dir = "/mnt/gluster/hdfs/name" 
set.hadoop.hdfs_data_dir = "#{node[:hadoop][:userhome]}/hdfs/data"

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
set.hbase.download_url = "http://archive.apache.org/dist/hadoop/hbase/hbase-0.20.2/hbase-0.20.2.tar.gz"
set.hbase.core_dir = "#{node[:hadoop][:userhome]}/hbase"
set.hbase.conf_dir = "#{node[:hbase][:core_dir]}/conf"

# Zookeeper settings
set.hadoop.zookeeper.data_dir = "#{node[:hadoop][:userhome]}/zookeeper/data"

# Daemons in start order
set.hadoop.hadoop_daemons = %w{ name_node data_node secondary_name_node job_tracker task_tracker }
set.hadoop.hbase_daemons = %w{ zookeeper hbase_master region_server }

set.hadoop.name_node.name = "namenode"
#set.hadoop.name_node.fqdn = "ras-namenode2.vm.griddynamics.net"

set.hadoop.name_node_master.name = "namenode"
set.hadoop.data_node.name = "datanode"
set.hadoop.secondary_name_node.name = "secondarynamenode"
set.hadoop.job_tracker.name = "jobtracker"
set.hadoop.task_tracker.name = "tasktracker"
set.hadoop.zookeeper.name = "zookeeper"
set.hadoop.hbase_master.name = "master"
set.hadoop.region_server.name = "regionserver"

