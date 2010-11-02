include_recipe "hadoop"

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
