class docker {

	package { 'docker.io':
		ensure => installed,
	}

	file { 'etc:docker':
		path => '/etc/docker',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => Package['docker.io'],
	}

	schedule { 'diario':
		period => daily,
		repeat => 1,
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
		schedule => 'diario',
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

	# Remove contêiner parado
	exec { 'docker:rm:haproxy:mysql':
		command => '/usr/bin/docker rm haproxy_mysql',
		require => Exec['docker:build:haproxy:common'],
		unless => '/usr/bin/docker top haproxy_mysql', # não está rodando
		onlyif => '/usr/bin/docker diff haproxy_mysql', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:haproxy:mysql':
		command => '/usr/bin/docker run -d -p 13306:3306 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/haproxy/mysql.cfg:/etc/haproxy/haproxy.cfg:ro --name="haproxy_mysql" haproxy:common',
		require => [
			Exec['docker:build:haproxy:common'],
			Exec['docker:rm:haproxy:mysql'],
			File['docker:haproxy:mysql:haproxy.cfg'],
		],
		unless => '/usr/bin/docker top haproxy_mysql', # não está rodando
	}

}


class docker::memcached inherits docker {

	file { 'etc:docker:memcached':
		path => '/etc/docker/memcached',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => File['etc:docker'],
	}

	file { 'etc:docker:memcached:Dockerfile':
		path => '/etc/docker/memcached/Dockerfile',
		source => 'puppet:///modules/docker/Dockerfile-memcached',
		owner => root,
		group => root,
		mode => 0640,
		require => File['etc:docker:memcached'],
	}

	exec { 'docker:build:memcached:common':
		command => '/usr/bin/docker build -t memcached:common .',
		cwd => '/etc/docker/memcached',
		require => File['etc:docker:memcached:Dockerfile'],
		schedule => 'diario',
	}

	# Remove contêiner parado
	exec { 'docker:rm:memcached:common':
		command => '/usr/bin/docker rm memcached_common',
		require => Exec['docker:build:memcached:common'],
		unless => '/usr/bin/docker top memcached_common', # não está rodando
		onlyif => '/usr/bin/docker diff memcached_common', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:memcached:common':
		command => '/usr/bin/docker run -d -p 11211:11211 -v /dev/log:/dev/log:rw --name="memcached_common" memcached:common /usr/bin/memcached -u memcache -m 256',
		require => [
			Exec['docker:build:memcached:common'],
			Exec['docker:rm:memcached:common'],
		],
		unless => '/usr/bin/docker top memcached_common', # não está rodando
	}

}
