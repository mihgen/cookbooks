include_recipe "hadoop::name_node"
include_recipe "keepalived"
include_recipe "hadoop::keepalived"

service "keepalived" do
  action :nothing
end

template node[:keepalived][:config] do
  mode 0600
  source "keepalived.conf.erb"
  variables({
    :weights => node[:hadoop][:ha][:master]
  })
  notifies :restart, resources(:service => "keepalived")
end
