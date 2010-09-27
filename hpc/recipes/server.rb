
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

clients = search(:node, %q{run_list:"recipe[hpc::client]"}).map{ |e| e["ipaddress"] }

template "/etc/exports" do
  source "exports.erb" 
  variables :clients => clients
end
