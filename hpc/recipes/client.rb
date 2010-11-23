include_recipe "hpc"

%w{opkg-c3
opkg-mpich
opkg-sc3
opkg-switcher
opkg-torque-client
opkg-maui-client
}.each { |pkg| package pkg }

service "pbs_mom" do
  action [ :enable, :start ]
end

server = search(:node, %q{run_list:"recipe[hpc::server]"})
server_ip = server.map{ |e| e["ipaddress"] }
server_fqdn = server.map{ |e| e["fqdn"] }

mount "/home" do
  device "#{server_ip}:/home"
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

template "/var/torque/server_name" do
  source "server_name.erb" 
  mode 0644
  variables :server_fqdn => server_fqdn
  notifies :restart, resources(:service => "pbs_mom")
end

template "/var/torque/mom_priv/config" do
  source "mom_config.erb" 
  mode 0644
  variables :server_fqdn => server_fqdn
  notifies :restart, resources(:service => "pbs_mom")
end
