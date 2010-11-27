include_recipe "keepalived"
include_recipe "glusterfs"
include_recipe "hadoop::keepalived"

service "keepalived" do
  action :nothing
end

template node[:keepalived][:config] do
  mode 0600
  source "keepalived.conf.erb"
  variables({
    :weights => node[:hadoop][:ha][:backup]
  })
  notifies :restart, resources(:service => "keepalived")
end
