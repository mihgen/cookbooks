include_recipe "ssh_known_hosts"
include_recipe "java6"

cookbook_file "/etc/yum.repos.d/oscar-rhel5-x86_64.repo" do
  source "oscar-rhel5-x86_64.repo"
  mode 0644
end

directory node[:hpc][:dir_to_store]

%w{
  autoconf automake bison byacc cscope ctags
  cvs diffstat doxygen elfutils flex indent intltool libtool ltrace oprofile oprofile-gui 
  patchutils python-ldap rcs rpm-build swig systemtap texinfo valgrind gettext 
  blas blas-devel
  boost boost-devel
  emacs nano mc vim-enhanced
  gcc gcc-c++ gcc-gfortran
  gdb gdbm
  glibc glibc-devel
  gnuplot
  htop
  iperf
  lapack lapack-devel
  python python-crypto python-devel python-libs python-numeric 
  python-dateutil python-matplotlib mod_python
  python-setuptools python-openbabel
  qt qt-devel qt-x11
  screen unzip
  sysstat
  strace tcpdump
  tcl tk
}.each do |pkg| 
  package pkg do
    action :install
  end
end 

yum_package "glibc-devel" do
  arch "i686"
  ignore_failure true
end

package "torque" do
  version "2.1.10-8.fc12"
end

%w{ rpcbind rpcidmapd }.each do |svc|
  service svc do
    action [ :enable, :start ]
  end
end

%w{ gnuplot-py-1.8.tar.gz dmd.2.049.zip }.each do |pkg|
  remote_file "#{node[:hpc][:dir_to_store]}/#{pkg}" do
    source "#{node[:hpc][:storage_url]}/#{pkg}"
    not_if { ::File.exists?("#{node[:hpc][:dir_to_store]}/#{pkg}") }
    action :create_if_missing
  end
end

# Issue with checking if package already installed: http://tickets.opscode.com/browse/CHEF-1889
easy_install_package "numpy" do
  version "1.5.1"
end

easy_install_package "scipy" do
  version "0.8.0"
end

# gnuplot needs numpy installed
%w{ gnuplot-py-1.8.tar.gz }.each do |pkg|
  bash "Install #{pkg}" do
    cwd node[:hpc][:dir_to_store]
    code <<-EOH
    tar xzf #{pkg}
    cd #{pkg.scan(/(\S+)\.tar\.gz/)}
    python ./setup.py install
    EOH
    not_if do
      ::Dir["/usr/lib/python2.6/site-packages/#{pkg.scan(/(\w+).*/)}*"].any?
    end
  end
end

bash "Installing dmd compiler" do
  cwd node[:hpc][:dir_to_store]
  code <<-EOH
  /usr/bin/unzip dmd.2.049.zip -d /opt
  ln -sf /opt/dmd2/linux/bin/dmd.conf /etc/dmd.conf
  ln -sf /opt/dmd2/linux/lib/libphobos2.a /usr/lib/libphobos2.a
  EOH
  not_if do
    ::File.exists?("/opt/dmd2/linux/bin/dmd") 
  end
end

template "/etc/profile.d/dmd.sh" do
  source "dmd.sh.erb"
  mode 0644
  variables(:path => "/opt/dmd2/linux/bin")
end

package "ganglia-gmond" do
  version "3.1.2-4.fc12"
end

service "gmond" do
  action :enable
end

template "/etc/ganglia/gmond.conf" do
  source "gmond.conf.erb" 
  mode 0644
  notifies :restart, resources(:service => "gmond")
end

service "gmond" do
  action :start
end
