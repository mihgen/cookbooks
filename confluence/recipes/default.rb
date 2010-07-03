include_recipe "java6"
storage_url = "http://s3.cluster.sgu.ru/packages"

%w{ libXp libXp-devel }.each do |pkg|
  package pkg
end

["/root/packages", "/usr/local/confluence-data"].each do |dir|
  directory dir do
  #  owner "root"
  #  group "root"
  #  mode "0755"
    action :create
  end
end

confl_pkg = "confluence-3.2.1_01-std.tar.gz"
confl_dir = confl_pkg.scan(/(\S+)\.tar\.gz/).to_s

%W{ #{confl_pkg} }.each do |pkg|
  remote_file "/root/packages/#{pkg}" do
    source "#{storage_url}/#{pkg}"
    not_if { ::File.exists?("/root/packages/#{pkg}") }
    action :create_if_missing
#    checksum "d78b755476bc5061b66fdfbd0b4ede2fe4f9b9d43575634b6c65a7e7547aab29"
  end
end

conf_file="/usr/local/#{confl_dir}/confluence/WEB-INF/classes/confluence-init.properties"
bash "install_confluence_and_change_java_home_in_config" do
# TODO change following line to relevant
  not_if { ::File.exists?(conf_file) }
  code <<-EOH
  tar -zxf /root/packages/#{confl_pkg} -C /usr/local
  chown -R root:root /usr/local/#{confl_dir}
  EOH
end

template conf_file do
  variables :confl_data_dir => "/usr/local/confluence-data"
  source "confluence-init.properties.erb"
end
