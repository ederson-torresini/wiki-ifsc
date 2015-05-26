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
include mysql::bootstrap
#include mysql::cluster

node "puppet" {

	package { 'puppetmaster':
		ensure => installed,
	}

	service { 'puppetmaster':
		ensure => running,
		enable => true,
	}

	include syslog::server
	include gluster::bootstrap
	include docker::php-fpm::limpeza

}

node "wiki0" {

	include syslog::client
	include gluster::common
	include docker::haproxy
	include docker::memcached
	include docker::php-fpm::0
	include docker::php-fpm::1
	include docker::nginx::0
	include docker::nginx::1
	include docker::varnish
	include www::mediawiki
	include www::owncloud

}

node "wiki1" {

	include syslog::client
	include gluster::common
	include docker::haproxy
	include docker::memcached
	include docker::php-fpm::0
	include docker::php-fpm::1
	include docker::nginx::0
	include docker::nginx::1
	include docker::varnish
	include www::mediawiki
	include www::owncloud

}
