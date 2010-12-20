include_recipe "hpc"

%w{
opkg-mpich
opkg-mpich-server
opkg-switcher
opkg-switcher-server
nfs-utils nfswatch
}.each { |pkg| package pkg }

%w{ torque-server torque-gui libtorque-devel torque-client }.each do |pkg|
  package pkg do
    version "2.1.10-8.fc12"
  end
end

%w{ nfs pbs_server }.each do |svc|
  service svc do
    action [ :enable, :start ]
  end
end

clients = search(:node, %q{run_list:"recipe[hpc::client]"})
ser_fqdn = search(:node, %q{run_list:"recipe[hpc::server]"}).map{ |e| e["fqdn"] }
cli_ips = clients.map{ |e| e["ipaddress"] }
cli_fqdn = clients.map{ |e| e["fqdn"] }

template "/var/torque/server_name" do
  source "server_name.erb" 
  mode 0644
  variables :server_fqdn => ser_fqdn
  notifies :restart, resources(:service => "pbs_server")
end

template "/opt/syncer" do
  source "syncer.erb" 
  mode 0755
  variables :hosts => cli_fqdn
end

template "/etc/exports" do
  source "exports.erb" 
  variables :clients => cli_ips
end

template "/var/torque/server_priv/nodes" do
  source "nodes.erb" 
  mode 0644
  variables :clients => cli_fqdn
  notifies :restart, resources(:service => "pbs_server")
end

pkg = "maui-3.3.tar"
remote_file "#{node[:hpc][:dir_to_store]}/#{pkg}" do
  source "#{node[:hpc][:storage_url]}/#{pkg}"
  not_if { ::File.exists?("#{node[:hpc][:dir_to_store]}/#{pkg}") }
  action :create_if_missing
end

script "Install maui from source" do
  interpreter "bash"
  user "root"
  cwd node[:hpc][:dir_to_store]
  code <<-EOH
  tar -xf maui-3.3.tar
  cd maui-3.3
  ./configure
  make
  make install
  EOH
  not_if do
    ::File.exists?("/usr/local/maui/sbin/maui") 
  end
end

cookbook_file "/etc/init.d/maui" do
  source "init_maui"
  mode "0755"
end

service "maui" do
  action [ :enable, :start ]
end

bash "Configure qmgr" do
user "root"
  cwd "/tmp"
  code <<-EOH
    qmgr <<EOF
#
# Create queues and set their attributes.
#
#
# Create and define queue workq
#
create queue workq
set queue workq queue_type = Execution
set queue workq resources_max.cput = 240:00:00
set queue workq resources_max.ncpus = 32
set queue workq resources_max.nodect = 4
set queue workq resources_max.walltime = 300:00:00
set queue workq resources_min.cput = 00:00:01
set queue workq resources_default.cput = 300:00:00
set queue workq resources_default.ncpus = 1
set queue workq resources_default.nodect = 1
set queue workq resources_default.walltime = 10000:00:00
set queue workq resources_available.nodect = 4
set queue workq enabled = True
set queue workq started = True
#
# Set server attributes.
#
set server scheduling = True
set server default_queue = workq
set server log_events = 64
set server mail_from = adm
set server query_other_jobs = True
set server resources_available.ncpus = 32
set server resources_available.nodect = 4
set server resources_available.nodes = 4
set server resources_max.ncpus = 32
set server resources_max.nodes = 4
set server scheduler_iteration = 60
set server node_check_rate = 150
set server tcp_timeout = 6
set server keep_completed = 300
EOF
  EOH
end

