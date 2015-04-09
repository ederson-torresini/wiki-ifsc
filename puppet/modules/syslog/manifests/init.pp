class syslog {

	package { 'logrotate':
		ensure => installed,
	}
	
	package { 'rsyslog':
		ensure => installed,
	}

	service { 'rsyslog':
		ensure => running,
		enable => true,
	}

}

class syslog::client inherits syslog {

	file { 'client.conf':
		path => '/etc/rsyslog.d/99-cluster.conf',
		source => 'puppet:///modules/syslog/client.conf',
		owner => 'root',
		group => 'root',
		mode => 0644,
		require => Package['rsyslog'],
	}

	Service <| title == 'rsyslog' |> {
		subscribe => File['client.conf'],
	}

}

class syslog::server inherits syslog {

	file { 'rsyslog:dir':
		path => '/var/log/cluster',
		ensure => directory,
		owner => root,
		group => adm,
		mode => 0755,
		require => Package['rsyslog'],
	}

	file { 'server.conf':
		path => '/etc/rsyslog.d/99-cluster.conf',
		source => 'puppet:///modules/syslog/server.conf',
		owner => 'root',
		group => 'root',
		mode => 0644,
		require => [
			Package['rsyslog'],
			File['rsyslog:dir'],
		],
	}

	Service <| title == 'rsyslog' |> {
		subscribe => File['server.conf'],
	}

	file { 'logrotate.conf':
		path => '/etc/logrotate.d/cluster',
		source => 'puppet:///modules/syslog/logrotate.conf',
		owner => root,
		group => root,
		mode => 0644,
		require => Package['logrotate'],
	}

}
