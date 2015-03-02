# site.pp

package { 'puppet':
	ensure => installed,
}

service { 'puppet':
	ensure => running,
	enable => true,
}

node "puppet" {

	package { 'puppetmaster':
		ensure => installed,
	}

	service { 'puppetmaster':
		ensure => running,
		enable => true,
	}

}

node "wiki0" {
}

node "wiki1" {
}
