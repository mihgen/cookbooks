ver = "0.6.8"
set[:cassandra][:version] = ver
set[:cassandra][:tar_url] = "http://www.sai.msu.su/apache//cassandra/#{ver}/apache-cassandra-#{ver}-bin.tar.gz"

set[:cassandra][:cluster_name] = "Cassandra Cluster"
set[:cassandra][:keyspace_reservations_rf] = "3"
set[:cassandra][:rpc_timeout_ms] = "40000"

set[:cassandra][:xms] = "1G"
set[:cassandra][:xmx] = "1G"
set[:cassandra][:jmxport] = "9080"
