class haproxy::common {

	exec { 'haproxy:wiki':
		command => '/usr/bin/docker build -t haproxy:wiki .',
		cwd => '/etc/wiki-ifsc/docker/haproxy',
		require => Exec['git:clone'],
	}

}

class haproxy::mysql inherits haproxy::common {

	#exec { 'docker:run:haproxy:mysql':
	#	command => '/usr/bin/docker run -a /etc/wiki-ifsc/docker/ha'

}
