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
  screen
  sysstat
  strace tcpdump
  tcl tk
}.each { |pkg| package pkg } 

storage_url = "http://s3.cluster.sgu.ru/packages"
directory "/root/packages" 

%w{ Python-2.6.5.tar.bz2 setuptools-0.6c11.tar.gz gnuplot-py-1.8.tar.gz }.each do |pkg|
  remote_file "/root/packages/#{pkg}" do
    source "#{storage_url}/#{pkg}"
    not_if { ::File.exists?("/root/packages/#{pkg}") }
    action :create_if_missing
  end
end

bash "Install Python 2.6.5" do
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

%w{ setuptools-0.6c11.tar.gz gnuplot-py-1.8.tar.gz }.each do |pkg|
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

%w{ numpy scipy }.each do |pkg|
  easy_install_package pkg do
    easy_install_binary "/usr/local/bin/easy_install-2.6"
  end
end
