remote_file "/etc/yum.repos.d/oscar-rhel5-x86_64.repo" do
  source "oscar-rhel5-x86_64.repo"
  mode 0644
end


package "epel-release" do
  action :remove
end

%w{
  autoconf automake bison byacc cscope ctags
  cvs diffstat doxygen elfutils flex frysk indent intltool libtool ltrace oprofile oprofile-gui 
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
