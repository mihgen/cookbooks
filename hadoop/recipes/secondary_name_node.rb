include_recipe "hadoop"

template "#{node[:hadoop][:conf_dir]}/secondarynamenodes" do
  owner node[:hadoop][:user]
  group node[:hadoop][:user]
  mode 0644
  source "secondarynamenodes.erb"
  variables({
    :hosts => search(:node, %q{run_list:"recipe[hadoop::secondary_name_node]"}).map{ |e| e["fqdn"] }
  })
end
