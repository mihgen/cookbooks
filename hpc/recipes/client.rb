include_recipe "hpc"

%w{opkg-c3-4.1.3-1.noarch
opkg-maui-3.2.6p19-8.noarch
opkg-mpich-1.2.7-9.noarch
opkg-sc3-1.2-5.noarch
opkg-switcher-1.0.7-2.noarch
opkg-torque-2.1.10-4.noarch
}.each { |pkg| package pkg }
