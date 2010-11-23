v = node[:glusterfs][:version]

remote_file "/tmp/glusterfs-#{v}.src.rpm" do
  source "http://download.gluster.com/pub/gluster/glusterfs/3.0/LATEST/CentOS/glusterfs-#{v}.src.rpm"
  not_if { ::File.exists?("/tmp/glusterfs-#{v}.src.rpm") }
  action :create_if_missing
end

%w{ rpm-build libibverbs-devel bison flex }.each do |p|
  package p
end

bash "Building rpm packages from src rpm" do
  cwd "/tmp"
  code <<-EOH
  rpmbuild --rebuild glusterfs-#{v}.src.rpm
  EOH
  not_if { ::File.exists?("/usr/src/redhat/RPMS/i386/glusterfs-common-#{v}.i386.rpm") }
end

%W{ glusterfs-common-#{v}.i386.rpm glusterfs-server-#{v}.i386.rpm glusterfs-client-#{v}.i386.rpm glusterfs-devel-#{v}.i386.rpm }.each do |p|
  # package "/usr/src/redhat/RPMS/i386/#{p}"   That's doesn't work. Seems to be http://tickets.opscode.com/browse/CHEF-714 still unresolved.
  bash "Installing rpm package #{p}" do
    cwd "/usr/src/redhat/RPMS/i386/"
    code <<-EOH
    rpm -Uhv #{p}
    EOH
    not_if { ::File.exists?("/usr/sbin/glusterfsd") }
  end
end

service "glusterfsd" do
  action :enable
end

[ node[:glusterfs][:storage_dir], node[:glusterfs][:mount_dir] ].each do |dir|
  directory dir do
    mode "0755"
    action :create
  end
end

%w{ glusterfs.vol glusterfsd.vol }.each do |tmpl|
  template "#{node[:glusterfs][:conf_dir]}/#{tmpl}" do
    mode 0644
    source "#{tmpl}.erb"
    variables({
      :gluster_hosts => search(:node, %q{run_list:"recipe[glusterfs]"}).map{ |e| e["fqdn"] }
    })
    notifies :restart, resources(:service => "glusterfsd")
  end
end

# TODO: mount it. Notification if glusterfs.vol changes??
