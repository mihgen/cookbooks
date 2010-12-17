include_recipe "hpc"

%w{opkg-c3
opkg-c3-server
opkg-maui
opkg-maui
opkg-mpich
opkg-mpich-server
opkg-sc3
opkg-sc3-server
opkg-switcher
opkg-switcher-server
opkg-torque
opkg-torque-server
nfs-utils nfswatch
}.each { |pkg| package pkg }

clients = search(:node, %q{run_list:"recipe[hpc::client]"})
cli_ips = clients.map{ |e| e["ipaddress"] }
cli_fqdn = clients.map{ |e| e["fqdn"] }

template "/etc/exports" do
  source "exports.erb" 
  variables :clients => cli_ips
end

service "pbs_server" do
  action :enable
end

template "/var/torque/server_priv/nodes" do
  source "nodes.erb" 
  mode 0644
  variables :clients => cli_fqdn
  notifies :restart, resources(:service => "pbs_server")
end

%w{ nfs pbs_sched }.each do |svc|
  service svc do
    action [ :enable, :start ]
  end
end

