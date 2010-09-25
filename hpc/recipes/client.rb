
%w{opkg-c3
opkg-maui
opkg-mpich
opkg-sc3
opkg-switcher
opkg-torque
}.each { |pkg| package pkg }

server = search(:node, "*:*").select { |e| e.run_list.run_list_items.select{ |i| i.name == "hpc::server" }.any? }.map{ |e| e["ipaddress"] }

mount "/home" do
  device "#{server}:/home"
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

