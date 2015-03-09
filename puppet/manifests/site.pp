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
	include docker::haproxy::mysql
	include memcached::common

}

node "wiki1" {

	include gluster::common
	include docker::haproxy::mysql
	include memcached::common

}
