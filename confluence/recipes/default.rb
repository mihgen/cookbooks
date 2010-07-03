include_recipe "java6"
storage_url = "http://s3.cluster.sgu.ru/packages"
confl_pkg = "confluence-3.2.1_01-std.tar.gz"
confl_dir = confl_pkg.scan(/(\S+)\.tar\.gz/).to_s

%w{ libXp libXp-devel }.each do |pkg|
  package pkg
end

group "wiki" do
end

user node[:confluence][:user] do
  comment "Confluence Wiki"
  gid node[:confluence][:user]
  home "/usr/local/#{confl_dir}"
  shell "/bin/bash"
end

["/root/packages", "/usr/local/confluence-data"].each do |dir|
  directory dir do
    mode 0755
    owner "#{node[:confluence][:user]}"
    group "#{node[:confluence][:user]}"
  end
end

%W{ #{confl_pkg} }.each do |pkg|
  remote_file "/root/packages/#{pkg}" do
    source "#{storage_url}/#{pkg}"
    not_if { ::File.exists?("/root/packages/#{pkg}") }
    action :create_if_missing
  end
end

conf_file="/usr/local/#{confl_dir}/confluence/WEB-INF/classes/confluence-init.properties"
bash "install_confluence_and_change_java_home_in_config" do
  not_if { ::File.exists?(conf_file) }
  code <<-EOH
  tar -zxf /root/packages/#{confl_pkg} -C /usr/local
  chown -R #{node[:confluence][:user]}:#{node[:confluence][:user]} /usr/local/#{confl_dir}
  EOH
end

template conf_file do
  group "#{node[:confluence][:user]}"
  owner "#{node[:confluence][:user]}"
  variables :confl_data_dir => "/usr/local/confluence-data"
  source "confluence-init.properties.erb"
end

template "/usr/local/#{confl_dir}/.bash_profile" do
  group "#{node[:confluence][:user]}"
  owner "#{node[:confluence][:user]}"
  source "bash_profile.erb"
end
