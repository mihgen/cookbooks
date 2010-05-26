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


storage_ulr = "http://s3.cluster.sgu.ru/packages"

%w{ Python-2.6.5.tar.bz2 numpy-1.4.1.tar.gz gnuplot-py-1.8.tar.gz }.each do |pkg|
  remote_file "/tmp/#{pkg}" do
    source "#{storage_ulr}/#{pkg}"
    not_if { ::File.exists?("/tmp/#{pkg}") }
  end
end

bash "Install Python 2.6.5" do
  cwd "/tmp"
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

%w{ numpy-1.4.1.tar.gz gnuplot-py-1.8.tar.gz }.each do |pkg|
  bash "Install Python 2.6.5 #{pkg} module" do
    cwd "/tmp"
    code <<-EOH
    tar xzf #{pkg}
    cd #{pkg.scan(/(.*).tar.gz/)}
    /usr/local/bin/python2.6 setup.py install
    EOH
    not_if do
      ::Dir["/usr/local/lib/python2.6/site-packages/#{pkg.scan(/(\w+).*/)}*"].any?
    end
  end
end
