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

script "install_hadoop" do
  interpreter "bash"
  user "#{node[:hadoop][:user]}"
  group "#{node[:hadoop][:user]}"
  cwd "#{node[:hadoop][:userhome]}"
  code <<-EOH 
  tar -kxzf #{filename}
  ssh-keygen -q -N ""
  #cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys
  #chmod 600 /home/hadoop/.ssh/authorized_keys
  #ssh #{node[:hadoop][:host]} -o StrictHostKeyChecking='no'
  #exit
  EOH
end

unpack_dir = filename.scan(/(\S+)\.tar\.gz/).to_s
log "Unpack dir: #{unpack_dir}"

link "#{node[:hadoop][:userhome]}/#{unpack_dir}" do
  to node[:hadoop][:core_dir]
end

[ node[:hadoop][:hdfs_name], node[:hadoop][:hdfs_data] ].each do |dir|
  directory "#{dir}" do
    owner node[:hadoop][:user]
    group node[:hadoop][:user]
    recursive true
  end
end

#template "/home/hadoop/hadoop-0.19.2/conf/hadoop-site.xml" do
  #source "hadoop-site.xml.erb"
  #variables({
    #:host => "#{node[:hadoop][:host]}"
  #})
#end

#template "#{node[:hadoop][:userhome]}/hadoop-0.19.2/conf/hadoop-env.sh" do
  #source "hadoop-env.sh.erb"
#end

#execute "format" do
  #command "echo Y | bin/hadoop namenode -format"
  #cwd "#{node[:hadoop][:userhome]}/hadoop-0.19.2"
  #user "#{node[:hadoop][:user]}"
  #group "#{node[:hadoop][:user]}"
##  creates "/tmp/hadoop-#{node[:hadoop][:user]}/dfs/name/current/fsimage"
#end  

#execute "start_all" do
  #command "bin/start-all.sh #{node[:hadoop][:host]}"
  #cwd "#{node[:hadoop][:userhome]}/hadoop-0.19.2"
  #user "#{node[:hadoop][:user]}"
  #group "#{node[:hadoop][:user]}"
#end  

