template "#{node[:keepalived][:conf_dir]}/notify.sh" do
  mode 0600
  source "notify.sh.erb"
  #variables({
    #:weights => node[:hadoop][:ha][:master]
  #})
end
