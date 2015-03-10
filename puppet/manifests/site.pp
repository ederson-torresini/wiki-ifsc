package { 'puppet':
	ensure => installed,
}

service { 'puppet':
	ensure => running,
	enable => true,
}

package { 'git':
	ensure => installed,
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
	include docker::memcached
	include docker::php-fpm::0
	include docker::php-fpm::1
	include docker::nginx::0
	include docker::nginx::1
	include www::mediawiki

}

node "wiki1" {

	include gluster::common
	include docker::haproxy::mysql
	include docker::memcached
	include docker::php-fpm::0
	include docker::php-fpm::1
	include docker::nginx::0
	include docker::nginx::1
	include www::mediawiki

}
