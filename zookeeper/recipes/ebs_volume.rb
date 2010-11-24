#
# Cookbook Name:: zookeeper
# Recipe:: ebs_volume
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
data_dir = node[:zookeeper][:data_dir]

if node[:ec2]
  include_recipe "aws"
  include_recipe "xfs"
  include_recipe "ebs-snapshots"

  mount_point = "/mnt/zookeeper"

  begin
    aws = Chef::DataBagItem.load(:aws, :main)
  rescue
    Chef::Log.fatal("Could not find the 'main' item in the 'aws' data bag")
    raise
  end

  # callback to create data bag item for new volume if created
  ruby_block "store_#{data_dir}_#{node[:zookeeper][:cluster_name]}_volid" do
    block do
      ebs_vol_id = node[:aws][:ebs_volume]["#{data_dir}_#{node[:zookeeper][:cluster_name]}"][:volume_id]

      item = {
        "id" => "ebs_zookeeper_#{node[:zookeeper][:cluster_name]}_#{ebs_vol_id}",
        "cluster_name" => node[:zookeeper][:cluster_name],
        "volume_type" => "zookeeper",
        "volume_id" => ebs_vol_id
      }
      databag_item = Chef::DataBagItem.new
      databag_item.data_bag("zookeeper")
      databag_item.raw_data = item
      databag_item.save
      Chef::Log.info("Created #{item['id']} in #{databag_item.data_bag}")
    end
    action :nothing
  end

  ebs_vol_dev = node[:zookeeper][:ebs_vol_dev]

  ec2 = RightAws::Ec2.new(aws['aws_access_key_id'], aws['aws_secret_access_key'], :logger => Chef::Log)

  # index by aws_id
  all_volumes = ec2.describe_volumes.inject({}) do |accum, elem|
    accum[elem[:aws_id]] = elem
    accum
  end

  # filter only available volumes
  available_volumes = search(:zookeeper, "volume_type:zookeeper AND cluster_name:#{node[:zookeeper][:cluster_name]}").select do |ebs_info|
    all_volumes[ebs_info['volume_id']] && all_volumes[ebs_info['volume_id']][:aws_status] == 'available'
  end

  # shuffle the list to avoid a herd effect
  available_volumes.replace(available_volumes.sort_by { rand })

  # try to attach any of the available volumes
  aws_ebs_volume "#{data_dir}_#{node[:zookeeper][:cluster_name]}" do
    aws_access_key aws['aws_access_key_id']
    aws_secret_access_key aws['aws_secret_access_key']
    size node[:zookeeper][:ebs_vol_size]
    device ebs_vol_dev
    volume_ids available_volumes.collect { |v| v['volume_id'] }
    action :attach_first
    provider "aws_ebs_volume"
  end

  # try to create a volume if none are available
  aws_ebs_volume "#{data_dir}_#{node[:zookeeper][:cluster_name]}" do
    aws_access_key aws['aws_access_key_id']
    aws_secret_access_key aws['aws_secret_access_key']
    size node[:zookeeper][:ebs_vol_size]
    device ebs_vol_dev
    action [:create, :attach]
    provider "aws_ebs_volume"
    notifies :create, resources(:ruby_block => "store_#{data_dir}_#{node[:zookeeper][:cluster_name]}_volid"), :immediately
  end

  execute "mkfs.xfs #{ebs_vol_dev}" do
    only_if "xfs_admin -l #{ebs_vol_dev} 2>&1 | grep -qx 'xfs_admin: #{ebs_vol_dev} is not a valid XFS filesystem (unexpected SB magic number 0x00000000)'"
  end
  
  directory mount_point do
    owner "zookeeper"
    group "nogroup"
    mode 0755
  end

  mount mount_point do
    device ebs_vol_dev
    fstype "xfs"
    options "noatime"
    action :mount
  end

  directory data_dir do
    owner "zookeeper"
    group "nogroup"
    mode 0755
    recursive true
  end

  mount data_dir do
    device mount_point
    fstype "none"
    options "bind,rw"
    action :mount
  end

end
