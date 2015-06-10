class mysql::bootstrap {

	package { 'lsof':
		ensure => installed,
	}

	exec { 'apt-key':
		command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv BC19DDBA',
		creates => '/etc/apt/sources.list.d/galera.list',
	}

	file { 'galera.list':
		path => '/etc/apt/sources.list.d/galera.list',
		source => 'puppet:///modules/mysql/galera.list',
		owner => root,
		group => root,
		mode => 0644,
		require => Exec['apt-key'],
	}

	exec { 'aptitude update':
		command => '/usr/bin/aptitude update',
		subscribe => File['galera.list'],
		refreshonly => true,
		require => [
			Exec['apt-key'],
			File['galera.list'],
		],
	}

	package { 'galera-3':
		ensure => installed,
		require => Exec['aptitude update'],
	}

	package { 'galera-arbitrator-3':
		ensure => installed,
		require => Exec['aptitude update'],
	}

	package { 'mysql-wsrep-server':
		ensure => installed,
		require => [
			Exec['aptitude update'],
		]
	}

	exec { 'killall:mysqld':
		command => '/usr/bin/killall -9 mysqld',
		subscribe => Package['mysql-wsrep-server'],
		refreshonly => true,
		onlyif => '/bin/pidof mysqld',
	}

	file { 'my.cnf':
		path => '/etc/mysql/my.cnf',
		source => 'puppet:///modules/mysql/my.cnf',
		owner => root,
		group => mysql,
		mode => 0644,
		require => Package['mysql-wsrep-server'],
	}

	$sourceBootstrap = $hostname ? {
		'puppet' => 'puppet:///modules/mysql/wsrep.cnf-puppet-bootstrap',
		'web0' => 'puppet:///modules/mysql/wsrep.cnf-web0-bootstrap',
		'web1' => 'puppet:///modules/mysql/wsrep.cnf-web1-bootstrap',
	}

	file { 'wsrep.cnf':
		path => '/etc/mysql/conf.d/wsrep.cnf',
		source => $sourceBootstrap,
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	service { 'mysql':
		ensure => running,
		enable => true,
		subscribe => [
			Exec['killall:mysqld'],
			File['my.cnf'],
			File['wsrep.cnf'],
		],
	}
	
	file { 'init.sql':
		path => '/etc/mysql/init.sql',
		source => 'puppet:///modules/mysql/init.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:users:init':
		command => '/usr/bin/mysql --user=root < /etc/mysql/init.sql',
		require => [
			File['init.sql'],
		],
		subscribe => Service['mysql'],
		refreshonly => true,
		onlyif => '/usr/bin/mysql --user=root -e "show variables"',
	}

	file { 'bootstrap.sql':
		path => '/etc/mysql/bootstrap.sql',
		source => 'puppet:///modules/mysql/bootstrap.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:users:wsrep':
		command => '/usr/bin/mysql --user=root --password=root < /etc/mysql/bootstrap.sql',
		require => [
			Service['mysql'],
			File['bootstrap.sql'],
			Exec['mysql:users:init'],
		],
	}

}

class mysql::cluster inherits mysql::bootstrap {

	$sourceCluster = $hostname ? {
		'puppet' => 'puppet:///modules/mysql/wsrep.cnf-puppet-cluster',
		'web0' => 'puppet:///modules/mysql/wsrep.cnf-web0-cluster',
		'web1' => 'puppet:///modules/mysql/wsrep.cnf-web1-cluster',
	}

	File <| title == 'wsrep.cnf' |> {
		source => $sourceCluster,
	}

	file { 'cluster.sql':
		path => '/etc/mysql/cluster.sql',
		source => 'puppet:///modules/mysql/cluster.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:users:root':
		command => '/usr/bin/mysql --user=root --password=root < /etc/mysql/cluster.sql',
		require => [
			Service['mysql'],
			File['cluster.sql'],
			Exec['mysql:users:init'],
		],
	}

	file { 'haproxy.sql':
		path => '/etc/mysql/haproxy.sql',
		source => 'puppet:///modules/mysql/haproxy.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:users:haproxy':
		command => '/usr/bin/mysql --user=root --password=root < /etc/mysql/haproxy.sql',
		require => [
			Service['mysql'],
			File['haproxy.sql'],
		],
	}

}
