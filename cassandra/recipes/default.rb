include_recipe "java6"

remote_file "/tmp/cassandra-#{node[:cassandra][:version]}.tar.gz" do
  source node[:cassandra][:tar_url]
  not_if { ::File.exists?("/tmp/cassandra-#{node[:cassandra][:version]}.tar.gz") }
  action :create_if_missing
end

directory "/cassandra" do
  mode "0755"
  action :create
end

bash "Install Cassandra #{node[:cassandra][:version]}" do
  cwd "/cassandra"
  code <<-EOH
  tar xzf /tmp/cassandra-#{node[:cassandra][:version]}.tar.gz
  EOH
  not_if { ::File.exists?("/cassandra/apache-cassandra-#{node[:cassandra][:version]}/bin/cassandra") }
end

link "/cassandra/core" do
  to "/cassandra/apache-cassandra-#{node[:cassandra][:version]}"
end

template "/cassandra/core/conf/storage-conf.xml" do
  source "storage-conf.xml.erb"
  mode 0644
  #variables :seeds => search(:node, %Q{run_list:"recipe[cassandra]" AND cluster_name:"#{node[:cassandra][:cluster_name]}"}).map{ |e| e["fqdn"] }
  variables :seeds => search(:node, %Q{run_list:"recipe[cassandra]"}).map{ |e| e["fqdn"] }
end

template "/cassandra/core/bin/cassandra.in.sh" do
  source "cassandra.in.sh.erb"
  mode 0755
end
