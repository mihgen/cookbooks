
%w{opkg-c3
opkg-maui
opkg-mpich
opkg-sc3
opkg-switcher
opkg-torque
}.each { |pkg| package pkg }

server = search(:node, %q{run_list:"recipe[hpc::server]"}).map{ |e| e["ipaddress"] }

mount "/home" do
  device "#{server}:/home"
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

