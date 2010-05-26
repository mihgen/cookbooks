
package "haproxy" do
  action :install
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
end

service "haproxy" do
  action [:enable, :start]
end

webs = search(:node,"recipe:simple-httpd").map { |w| [ w["ipaddress"], w["fqdn"] ] }

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  variables(:webs => webs)
  notifies :restart, resources(:service => "haproxy")
end
