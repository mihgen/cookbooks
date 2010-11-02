include_recipe "java6"
include_recipe "ssh_known_hosts"

user "#{node[:hadoop][:user]}" do
  home "#{node[:hadoop][:userhome]}"
  comment "hadoop User"
end

filename = node[:hadoop][:download_url].scan(/\/([^\/]+)$/).to_s
log "filename: #{filename}"

log "Download URL: #{node[:hadoop][:download_url]}"

remote_file "#{node[:hadoop][:userhome]}/#{filename}" do
  owner node[:hadoop][:user]
  backup false
  source "#{node[:hadoop][:download_url]}"
  action :create
  not_if do File.exists?("#{node[:hadoop][:userhome]}/#{filename}") end
end

unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s
log "Unpack dir: #{unpack_dir}"

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

template "#{node[:hadoop][:core_dir]}/conf/core-site.xml" do
  source "core-site.xml.erb"
  variables({
    :master_host => search(:node, %q{run_list:"recipe[hadoop::master]"}).map{ |e| e["fqdn"] }
  })
end

