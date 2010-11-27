include_recipe "java6"
include_recipe "ssh_known_hosts"

user "#{node[:hadoop][:user]}" do
  home "#{node[:hadoop][:userhome]}"
  comment "hadoop User"
end

directory "#{node[:hadoop][:userhome]}/.ssh" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0700
end

%w{ id_rsa id_rsa.pub authorized_keys }.each do |file|
  cookbook_file "#{node[:hadoop][:userhome]}/.ssh/#{file}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    source file
    mode "0600"
  end
end

[ node[:hadoop][:download_url], node[:hbase][:download_url] ].each do |url|
  filename = url.scan(/\/([^\/]+)$/).to_s
  log "Downloading #{filename}..."

  remote_file "#{node[:hadoop][:userhome]}/#{filename}" do
    owner node[:hadoop][:user]
    backup false
    source "#{node[:hadoop][:download_url]}"
    action :create
    not_if do File.exists?("#{node[:hadoop][:userhome]}/#{filename}") end
  end

  unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s
  component = unpack_dir.scan(/(\w+)-.*/).to_s

  script "Install #{component}" do
    interpreter "bash"
    user "#{node[:hadoop][:user]}"
    group "#{node[:hadoop][:user]}"
    cwd "#{node[:hadoop][:userhome]}"
    code <<-EOH 
    tar -kxzf #{filename}
    EOH
    not_if do File.exists?("#{node[:hadoop][:userhome]}/#{unpack_dir}/conf") end
  end

  link node[component.to_sym][:core_dir] do
    to "#{node[:hadoop][:userhome]}/#{unpack_dir}"
  end
end

[ node[:hadoop][:hdfs_data_dir], node[:hadoop][:hdfs_name_dir], node[:hadoop][:scripts_dir], node[:hadoop][:zookeeper][:data_dir] ].each do |dir|
  directory dir do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    recursive true
  end
end


# USING FQDN FROM ATTRS OR SEARCH TO FILL IN fqdn[:daemon]
fqdn = {}
fqdn_search = {}
ha_master_fqdn = search(:node, %Q{run_list:"recipe[hadoop::ha_master]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found HA Master host at #{ha_master_fqdn}"
(node[:hadoop][:hadoop_daemons] + node[:hadoop][:hbase_daemons]).each do |daemon|
  fqdn_search[daemon.to_sym] = search(:node, %Q{run_list:"recipe[hadoop::#{daemon}]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
  if node[:hadoop][daemon.to_sym][:fqdn].to_s.any? 
    fqdn[daemon.to_sym] = [ *node[:hadoop][daemon.to_sym][:fqdn] ]
  else
    fqdn[daemon.to_sym] = fqdn_search[daemon.to_sym]
  end
  log "Found #{daemon} on: #{fqdn_search[daemon.to_sym].join(',')}. Set #{daemon} service FQDN to #{fqdn[daemon.to_sym].join(',')}"
end

template "#{node[:hadoop][:core_dir]}/conf/core-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "core-site.xml.erb"
  variables({
    :master_host => fqdn[:name_node]
  })
end

template "#{node[:hadoop][:core_dir]}/conf/mapred-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "mapred-site.xml.erb"
  variables({
    :master_host => fqdn[:job_tracker]
  })
end

%w{ hdfs-site.xml hadoop-env.sh }.each do |file|
  template "#{node[:hadoop][:core_dir]}/conf/#{file}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0644
    source "#{file}.erb"
  end
end

template "#{node[:hbase][:conf_dir]}/hbase-env.sh" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "hbase-env.sh.erb"
end

template "#{node[:hadoop][:zookeeper][:data_dir]}/myid" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "myid.erb"
  variables({
    :zookeeper_id => fqdn[:zookeeper].index(node[:fqdn])
  })
end

template "#{node[:hbase][:conf_dir]}/hbase-site.xml" do
  source "hbase-site.xml.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  variables({
    :zk_hosts => fqdn[:zookeeper],
    :namenode_host => fqdn[:name_node]
  })
end

template "#{node[:hadoop][:scripts_dir]}/functions.sh" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "functions.sh.erb"
end

template "#{node[:hadoop][:scripts_dir]}/all.sh" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  source "all.sh.erb"
  variables({
    :daemons => node[:hadoop][:hadoop_daemons] + node[:hadoop][:hbase_daemons],
    :scripts_dir => node[:hadoop][:scripts_dir]
  })
end

node[:hadoop][:hadoop_daemons].each do |daemon|
  template "#{node[:hadoop][:scripts_dir]}/#{daemon}.sh" do
    source "scripts.sh.erb"
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    variables({
      :hadoop_or_hbase => "hadoop",
      :service => node[:hadoop][daemon.to_sym][:name],
      :hosts => fqdn_search[daemon.to_sym]
    })
  end
end

node[:hadoop][:hbase_daemons].each do |daemon|
  template "#{node[:hadoop][:scripts_dir]}/#{daemon}.sh" do
    source "scripts.sh.erb"
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    variables({
      :hadoop_or_hbase => "hbase",
      :service => node[:hadoop][daemon.to_sym][:name],
      :hosts => fqdn_search[daemon.to_sym]
    })
  end
end
  
# Special template for name_node. It needs to be started only on HA Master host.
template "#{node[:hadoop][:scripts_dir]}/name_node.sh" do
  source "scripts.sh.erb"
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0755
  variables({
    :hadoop_or_hbase => "hadoop",
    :service => node[:hadoop][:name_node][:name],
    :hosts => ha_master_fqdn
  })
end
