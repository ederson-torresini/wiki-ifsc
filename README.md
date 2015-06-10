# wiki-ifsc
Wiki institucional - IFSC

= Instalação =
cat >> /etc/hosts <<FIM

10.0.0.134 puppet syslog

10.0.0.132 web0

10.0.0.133 web1 mysql

192.168.1.156 puppet-ext

192.168.1.155 web0-ext

192.168.1.154 web1-ext

FIM
cat >> /etc/network/interfaces <<FIM
auto eth1
iface eth1 inet dhcp
FIM
ifup eth1
aptitude update; aptitude -y safe-upgrade; aptitude install -y puppet; puppet agent --disable


aptitude install -y puppetmaster git
git clone https://github.com/boidacarapreta/wiki-ifsc.git /etc/wiki-ifsc
service puppet stop
service puppetmaster stop
rm -rf /etc/puppet
ln -s /etc/wiki-ifsc/puppet /etc/puppet
service puppetmaster restart
service puppet restart


vi /etc/puppet/manifests/site.pp


puppet agent --enable
puppet agent --test


puppet cert sign web0.openstacklocal
puppet cert sign web1.openstacklocal
puppet agent --enable
