include_recipe "ssh_known_hosts"

remote_file "/etc/yum.repos.d/oscar-rhel5-x86_64.repo" do
  source "oscar-rhel5-x86_64.repo"
  mode 0644
end

package "epel-release" do
  action :remove
end

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
}.each { |pkg| package pkg } 

yum_package "glibc-devel" do
  arch "i386"
  ignore_failure true
end

yum_package "glibc-devel" do
  arch "i686"
  ignore_failure true
end

storage_url = "http://s3.cluster.sgu.ru/packages"
directory "/root/packages" 

%w{ Python-2.6.5.tar.bz2 setuptools-0.6c11.tar.gz gnuplot-py-1.8.tar.gz dmd.2.049.zip }.each do |pkg|
  remote_file "/root/packages/#{pkg}" do
    source "#{storage_url}/#{pkg}"
    not_if { ::File.exists?("/root/packages/#{pkg}") }
    action :create_if_missing
  end
end

bash "Installing Python 2.6.5" do
  cwd "/root/packages"
  code <<-EOH
  tar xf Python-2.6.5.tar.bz2
  cd Python-2.6.5
  ./configure
  make
  make altinstall
  EOH
  not_if do
    ::File.exists?("/usr/local/bin/python2.6") 
  end
end

%w{ setuptools-0.6c11.tar.gz }.each do |pkg|
  bash "Install #{pkg} for Python 2.6.5" do
    cwd "/root/packages"
    code <<-EOH
    tar xzf #{pkg}
    cd #{pkg.scan(/(\S+)\.tar\.gz/)}
    /usr/local/bin/python2.6 ./setup.py install
    EOH
    not_if do
      ::Dir["/usr/local/lib/python2.6/site-packages/#{pkg.scan(/(\w+).*/)}*"].any?
    end
  end
end

# Issue with checking if package already installed: http://tickets.opscode.com/browse/CHEF-1889
%w{ numpy scipy }.each do |pkg|
  easy_install_package pkg do
    easy_install_binary "/usr/local/bin/easy_install-2.6"
  end
end

# gnuplot needs numpy installed
%w{ gnuplot-py-1.8.tar.gz }.each do |pkg|
  bash "Install #{pkg} for Python 2.6.5" do
    cwd "/root/packages"
    code <<-EOH
    tar xzf #{pkg}
    cd #{pkg.scan(/(\S+)\.tar\.gz/)}
    /usr/local/bin/python2.6 ./setup.py install
    EOH
    not_if do
      ::Dir["/usr/local/lib/python2.6/site-packages/#{pkg.scan(/(\w+).*/)}*"].any?
    end
  end
end

bash "Installing dmd compiler" do
  cwd "/root/packages"
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
