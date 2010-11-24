maintainer       "Cook based on GoTime Inc.(ops@gotime.com), currently maintained by Mike Scherbakov"
maintainer_email "mihgen@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures zookeeper"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

%w{ centos }.each do |os|
  supports os
end

depends "java6"
#depends "runit"
