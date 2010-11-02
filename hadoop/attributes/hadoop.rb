#ntp Mash.new unless attribute?("hadoop")

#set_unless.hadoop.host = "localhost"
set_unless.hadoop.user = "hadoop"
set_unless.hadoop.userhome = "/hadoop"
set_unless.hadoop.download_url = "http://www.sai.msu.su/apache/hadoop/core/hadoop-0.21.0/hadoop-0.21.0.tar.gz"
set_unless.hadoop.core_dir = "#{node[:hadoop][:userhome]}/core"
set_unless.hadoop.hdfs_name = "#{node[:hadoop][:userhome]}/hdfs/name"
set_unless.hadoop.hdfs_data = "#{node[:hadoop][:userhome]}/hdfs/data"


#ntp[:servers] = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"] unless ntp.has_key?(:servers)
