class docker {

	package { 'docker':
		ensure => installed,
	}

	file { 'etc:docker':
		path => '/etc/docker',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => Package['docker'],
	}

}

class docker::haproxy inherits docker {

	file { 'etc:docker:haproxy':
		path => '/etc/docker/haproxy',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => File['etc:docker'],
	}
	
	file { 'etc:docker:haproxy:Dockerfile':
		path => '/etc/docker/haproxy/Dockerfile',
		source => 'puppet:///modules/docker/Dockerfile-haproxy',
		owner => root,
		group => root,
		mode => 0640,
		require => File['etc:docker:haproxy'],
	}

	exec { 'docker:build:haproxy:common':
		command => '/usr/bin/docker build -t haproxy:common .',
		cwd => '/etc/docker/haproxy',
		require => File['etc:docker:haproxy:Dockerfile'],
	}

}

class docker::haproxy::mysql inherits docker::haproxy {

	file { 'docker:haproxy:mysql:haproxy.cfg':
		path => '/etc/docker/haproxy/mysql.cfg',
		source => 'puppet:///modules/docker/haproxy_mysql.cfg',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:haproxy'],
	}

	exec { 'docker:run:haproxy:mysql':
		command => '/usr/bin/docker run -d -p 13306:3306 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/haproxy/mysql.cfg:/etc/haproxy/haproxy.cfg:ro --name="haproxy_mysql" haproxy:common',
		require => [
			Exec['docker:build:haproxy:common'],
			File['docker:haproxy:mysql:haproxy.cfg'],
		],
		unless => '/usr/bin/docker top haproxy_mysql',
	}

}
