include_recipe "java6"
include_recipe "ssh_known_hosts"

user "#{node[:hadoop][:user]}" do
  home "#{node[:hadoop][:userhome]}"
  comment "hadoop User"
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

directory "#{node[:hadoop][:userhome]}/.ssh" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0700
end

script "Generating ssh keypair" do
  interpreter "bash"
  user "#{node[:hadoop][:user]}"
  group "#{node[:hadoop][:user]}"
  cwd "#{node[:hadoop][:userhome]}"
  code <<-EOH 
  ssh-keygen -f #{node[:hadoop][:userhome]}/.ssh/id_rsa -q -N "" -C "Generated on #{node[:fqdn]}."
  EOH
  not_if do File.exists?("#{node[:hadoop][:userhome]}/.ssh/id_rsa") end
end

ruby_block "Load public key" do
  block do
    file = "#{node[:hadoop][:userhome]}/.ssh/id_rsa.pub"
    node[:hadoop][:ssh_public_key] = File.readlines(file) if File.exists?(file)
  end
end

log "Found public key: #{node[:hadoop][:ssh_public_key]}"

template "#{node[:hadoop][:userhome]}/.ssh/authorized_keys" do
  owner node[:hadoop][:user]
  mode 0600
  source "authorized_keys.erb"
  variables({
    :public_keys => search(:node, 'run_list:recipe\[hadoop*\]').map{ |e| e["hadoop"]["ssh_public_key"] unless e["hadoop"].nil? }
  })
end

template "#{node[:hadoop][:core_dir]}/conf/core-site.xml" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "core-site.xml.erb"
  variables({
    :master_host => search(:node, %q{run_list:"recipe[hadoop::name_node]"}).map{ |e| e["fqdn"] }
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
