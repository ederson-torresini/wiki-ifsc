# site.pp

package { 'puppet':
	ensure => installed,
}

service { 'puppet':
	ensure => running,
	enable => true,
}

include ntp

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
}

node "wiki1" {
	include gluster::common
}
