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

filename = node[:hadoop][:download_url].scan(/\/([^\/]+)$/).to_s

remote_file "#{node[:hadoop][:userhome]}/#{filename}" do
  owner node[:hadoop][:user]
  backup false
  source "#{node[:hadoop][:download_url]}"
  action :create
  not_if do File.exists?("#{node[:hadoop][:userhome]}/#{filename}") end
end

unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s

script "install_hadoop" do
  interpreter "bash"
  user "#{node[:hadoop][:user]}"
  group "#{node[:hadoop][:user]}"
  cwd "#{node[:hadoop][:userhome]}"
  code <<-EOH 
  tar -kxzf #{filename}
  EOH
  not_if do File.exists?("#{node[:hadoop][:userhome]}/#{unpack_dir}/conf") end
end

link node[:hadoop][:core_dir] do
  to "#{node[:hadoop][:userhome]}/#{unpack_dir}"
end

[ node[:hadoop][:hdfs_data], node[:hadoop][:scripts_dir] ].each do |dir|
  directory dir do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    recursive true
  end
end

unless node[:hadoop][:ha].nil?
  name_node_fqdn = node[:hadoop][:ha][:fqdn]
else
  name_node_fqdn = search(:node, %Q{run_list:"recipe[hadoop::name_node]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
end
log "Set NameNode to: #{name_node_fqdn} from recipe default."

template "#{node[:hadoop][:core_dir]}/conf/core-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "core-site.xml.erb"
  variables({
    :master_host => name_node_fqdn
  })
end

job_tracker_host = search(:node, %Q{run_list:"recipe[hadoop::job_tracker]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
log "Found job tracker at #{job_tracker_host}"

template "#{node[:hadoop][:core_dir]}/conf/mapred-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "mapred-site.xml.erb"
  variables({
    :master_host => job_tracker_host
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

template "#{node[:hadoop][:core_dir]}/conf/slaves" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "slaves.erb"
  variables({
    :hosts => []  #search(:node, %q{run_list:"recipe[hadoop::slave]"}).map{ |e| e["fqdn"] }
  })
end

template "#{node[:hadoop][:core_dir]}/conf/masters" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "masters.erb"
  variables({
    :hosts => []  #search(:node, %q{run_list:"recipe[hadoop::master]"}).map{ |e| e["fqdn"] }
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
end

%w{ name_node data_node secondary_name_node job_tracker task_tracker }.each do |daemon|
  hosts = search(:node, %Q{run_list:"recipe[hadoop::#{daemon}]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
  log "Found #{daemon} hosts: #{hosts.join(',')}"

  template "#{node[:hadoop][:scripts_dir]}/#{daemon}.sh" do
    source "scripts.sh.erb"
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    variables({
      :hadoop_or_hbase => "hadoop",
      :service => node[:hadoop][:daemons][daemon.to_sym],
      :hosts => hosts 
    })
  end
end

%w{ zookeeper hbase_master region_server }.each do |daemon|
  hosts = search(:node, %Q{run_list:"recipe[hadoop::#{daemon}]" AND env_id:#{node[:hadoop][:env_id]}}).map{ |e| e["fqdn"] }
  log "Found #{daemon} hosts: #{hosts.join(',')}"

  template "#{node[:hadoop][:scripts_dir]}/#{daemon}.sh" do
    source "scripts.sh.erb"
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    mode 0755
    variables({
      :hadoop_or_hbase => "hadoop",
      :service => node[:hadoop][:daemons][daemon.to_sym],
      :hosts => hosts 
    })
  end
end
