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

[ node[:hadoop][:hdfs_name], node[:hadoop][:hdfs_data] ].each do |dir|
  directory "#{dir}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    recursive true
  end
end

if node[:hadoop][:ha].any?
  name_node_fqdn = node[:hadoop][:ha][:fqdn]
else
  name_node_fqdn = search(:node, %q{run_list:"recipe[hadoop::name_node]"}).map{ |e| e["fqdn"] }
end

template "#{node[:hadoop][:core_dir]}/conf/core-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "core-site.xml.erb"
  variables({
    :master_host => name_node_fqdn
  })
end

template "#{node[:hadoop][:core_dir]}/conf/mapred-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "mapred-site.xml.erb"
  variables({
    :master_host => search(:node, %q{run_list:"recipe[hadoop::job_tracker]"}).map{ |e| e["fqdn"] }
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
