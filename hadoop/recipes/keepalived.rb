template "#{node[:keepalived][:conf_dir]}/notify.sh" do
  mode 0700
  source "notify.sh.erb"
  #variables({
    #:weights => node[:hadoop][:ha][:master]
  #})
end
