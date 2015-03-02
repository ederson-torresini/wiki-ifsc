# site.pp

package { 'puppet':
	ensure => installed,
}

service { 'puppet':
	ensure => running,
	enable => true,
}

include ntp
#include mysql::bootstrap
include mysql::cluster

node "puppet" {

	exec { 'garethr-docker':
		command => '/usr/bin/puppet module install garethr-docker',
		creates => '/etc/puppet/modules/docker/metadata.json',
	}

	package { 'puppetmaster':
		ensure => installed,
	}

	service { 'puppetmaster':
		ensure => running,
		enable => true,
	}

	include gluster::bootstrap

}

node "wiki0" {
	include gluster::common
}

node "wiki1" {
	include gluster::common
}
