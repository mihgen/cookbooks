
%w{ gcc gcc-c++ openssl-devel popt }.each do |p|
  package p
end

remote_file "/tmp/keepalived-#{node[:keepalived][:version]}.tar.gz" do
  source "http://www.keepalived.org/software/keepalived-#{node[:keepalived][:version]}.tar.gz"
  mode "0644"
  not_if { ::File.exists?("/tmp/keepalived-#{node[:keepalived][:version]}.tar.gz") }
  action :create_if_missing
end

bash "untar keepalived" do
  user "root"
  cwd "/tmp"
  code %(tar zxf /tmp/keepalived-#{node[:keepalived][:version]}.tar.gz)
  not_if { File.exists? "/tmp/zookeeper-#{node[:keepalived][:version]}" }
end

bash "Compile and install keepalived" do
  user "root"
  cwd "/tmp/keepalived-#{node[:keepalived][:version]}"
  code <<-EOH
  ./configure
  make
  make install
  cd /etc/sysconfig/
  ln -s /usr/local/etc/sysconfig/keepalived .
  cd /etc/init.d/
  ln -s /usr/local/etc/rc.d/init.d/keepalived .
  ln -s /usr/local/etc/keepalived /etc/keepalived
  ln -s /usr/local/sbin/keepalived /usr/sbin/keepalived
  EOH
  not_if { File.exists? "/usr/sbin/keepalived" }
end

service "keepalived" do
  action :enable
end

