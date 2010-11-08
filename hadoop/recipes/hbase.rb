include_recipe "hadoop"

#user "#{node[:hbase][:user]}" do
  #home "#{node[:hbase][:userhome]}"
  #comment "hbase User"
#end

filename = node[:hbase][:download_url].scan(/\/([^\/]+)$/).to_s
log "filename: #{filename}"

log "Download URL: #{node[:hbase][:download_url]}"

remote_file "#{node[:hbase][:userhome]}/#{filename}" do
  owner node[:hbase][:user]
  backup false
  source "#{node[:hbase][:download_url]}"
  action :create
  not_if do File.exists?("#{node[:hbase][:userhome]}/#{filename}") end
end

unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s

script "install_hbase" do
  interpreter "bash"
  user "#{node[:hbase][:user]}"
  group "#{node[:hbase][:user]}"
  cwd "#{node[:hbase][:userhome]}"
  code <<-EOH 
  tar -kxzf #{filename}
  EOH
  not_if do File.exists?("#{node[:hbase][:userhome]}/#{unpack_dir}/conf") end
end

link node[:hbase][:core_dir] do
  to "#{node[:hbase][:userhome]}/#{unpack_dir}"
end

template "#{node[:hbase][:conf_dir]}/hbase-env.sh" do
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0644
  source "hbase-env.sh.erb"
end

template "#{node[:hbase][:conf_dir]}/hbase-site.xml" do
  source "hbase-site.xml.erb"
  owner node[:hbase][:user]
  group node[:hbase][:user]
  mode 0644
  variables({
    :zk_hosts => search(:node, %q{run_list:"recipe[hadoop::zookeeper]"}).map{ |e| e["fqdn"] },
    :namenode_host => search(:node, %q{run_list:"recipe[hadoop::name_node]"}).map{ |e| e["fqdn"] }
  })
end

