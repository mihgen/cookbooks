#ntp Mash.new unless attribute?("hadoop")

#set_unless.hadoop.host = "localhost"
set_unless.hadoop.user = "hadoop"
set_unless.hadoop.userhome = "/hadoop"
set_unless.hadoop.download_url = "http://www.sai.msu.su/apache/hadoop/core/hadoop-0.21.0/hadoop-0.21.0.tar.gz"
set_unless.hadoop.core_dir = "#{node[:hadoop][:userhome]}/core"
set_unless.hadoop.conf_dir = "#{node[:hadoop][:core_dir]}/conf"
set_unless.hadoop.hdfs_name = "#{node[:hadoop][:userhome]}/hdfs/name"
set_unless.hadoop.hdfs_data = "#{node[:hadoop][:userhome]}/hdfs/data"

# Remote commands to start daemons:
hadoop_prestart = "cd #{node[:hadoop][:core_dir]}/bin; export JAVA_HOME=#{node[:java][:home]}; export HADOOP_HOME=#{node[:hadoop][:core_dir]}"
set.hadoop.name_node.start_cmd = "#{hadoop_prestart}; echo Y | #{node[:hadoop][:core_dir]}/bin/hadoop namenode -format; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} --script #{node[:hadoop][:core_dir]}/bin/hdfs start namenode"
set.hadoop.data_node.start_cmd = "#{hadoop_prestart}; ./hadoop-daemon.sh --config #{node[:hadoop][:conf_dir]} --script #{node[:hadoop][:core_dir]}/bin/hdfs start datanode"


#ntp[:servers] = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"] unless ntp.has_key?(:servers)
