#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright 2010, GoTime Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "java"
include_recipe "runit"

remote_file "/tmp/zookeeper-#{node[:zookeeper][:version]}.tar.gz" do
  source "http://mirrors.ibiblio.org/pub/mirrors/apache/hadoop/zookeeper/zookeeper-#{node[:zookeeper][:version]}/zookeeper-#{node[:zookeeper][:version]}.tar.gz"
  mode "0644"
end

user "zookeeper" do
  uid 61001
  gid "nogroup"
end

["/usr/lib/zookeeper-#{node[:zookeeper][:version]}", "/etc/zookeeper"].each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode 0755
  end
end

["/var/log/zookeeper", "/var/lib/zookeeper"].each do |dir|
  directory dir do
    owner "zookeeper"
    group "nogroup"
    mode 0755
  end
end

if node[:ec2]
  directory "/mnt/zookeeper" do
    owner "zookeeper"
    group "nogroup"
    mode 0755
  end

  # put lib dir on /mnt
  mount "/var/lib/zookeeper" do
    device "/mnt/zookeeper"
    fstype "none"
    options "bind,rw"
    action :mount
  end
end

bash "untar zookeeper" do
  user "root"
  cwd "/tmp"
  code %(tar zxf /tmp/zookeeper-#{node[:zookeeper][:version]}.tar.gz)
  not_if { File.exists? "/tmp/zookeeper-#{node[:zookeeper][:version]}" }
end

bash "copy zk root" do
  user "root"
  cwd "/tmp"
  code %(cp -r /tmp/zookeeper-#{node[:zookeeper][:version]}/* /usr/lib/zookeeper-#{node[:zookeeper][:version]})
  not_if { File.exists? "/usr/lib/zookeeper-#{node[:zookeeper][:version]}/lib" }
end

link "/usr/lib/zookeeper" do
  to "/usr/lib/zookeeper-#{node[:zookeeper][:version]}"
end

bash "copy zk conf" do
  user "root"
  cwd "/usr/lib/zookeeper"
  code %(cp -R ./conf/* /etc/zookeeper)
  not_if { File.exists? "/etc/zookeeper/log4j.properties" }
end

template "/etc/zookeeper/log4j.properties" do
  source "log4j.properties.erb"
  mode 0644
end

if node.role?("zookeeper")
  zk_servers = [node]
else
  zk_servers = []
end
zk_servers += search(:node, "role:zookeeper AND zookeeper_cluster_name:#{node[:zookeeper][:cluster_name]} NOT name:#{node.name}") # don't include this one, since it's already in the list

zk_servers.sort! { |a, b| a.name <=> b.name }

template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  mode 0644
  variables(:servers => zk_servers)
end

include_recipe "zookeeper::ebs_volume"

directory node[:zookeeper][:data_dir] do
  recursive true
  owner "zookeeper"
  group "nogroup"
  mode 0755
end

myid = zk_servers.collect { |n| n[:ipaddress] }.index(node[:ipaddress])

template "#{node[:zookeeper][:data_dir]}/myid" do
  source "myid.erb"
  owner "zookeeper"
  group "nogroup"
  variables(:myid => myid)
end

runit_service "zookeeper"

service "zookeeper" do
  subscribes :restart, resources(:template => "/etc/zookeeper/zoo.cfg")
end
