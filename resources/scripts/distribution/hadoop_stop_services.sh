for x in $(cd /etc/init.d; ls hadoop-*); do sudo service $x stop; done
