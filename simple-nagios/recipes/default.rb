include_recipe "simple-httpd"

%w{nagios nagios-plugins nagios-plugins-all}.each do |p|
  package p
end

service "nagios" do
  action [ :enable, :start ]
end

service "httpd" do
  supports :reload => true
end

remote_file "/etc/httpd/conf.d/nagios.conf" do
  source "nagios.conf"
  notifies :reload, resources(:service => "httpd")
end

remote_file "/etc/nagios/passwd" do
  source "nagios-passwd"
  owner "apache"
  group "apache"
  mode "0644"
end

remote_file "/etc/nagios/cgi.cfg" do 
  source "cgi.cfg"
  notifies :reload, resources(:service => "httpd")
end
