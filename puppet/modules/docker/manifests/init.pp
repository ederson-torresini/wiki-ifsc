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

	exec { 'docker:build:haproxy:latest':
		command => '/usr/bin/docker build -t haproxy:latest .',
		cwd => '/etc/docker/haproxy',
		subscribe => File['etc:docker:haproxy:Dockerfile'],
		refreshonly => true,
		timeout => 600,
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

	# Para contêiner desatualizado
	exec { 'docker:stop:haproxy:mysql':
		command => '/usr/bin/docker stop haproxy_mysql',
		subscribe => [
			Exec['docker:build:haproxy:latest'],
			File['docker:haproxy:mysql:haproxy.cfg'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top haproxy_mysql',
	}

	# Remove contêiner parado
	exec { 'docker:rm:haproxy:mysql':
		command => '/usr/bin/docker rm haproxy_mysql',
		require => Exec['docker:stop:haproxy:mysql'],
		unless => '/usr/bin/docker top haproxy_mysql', # não está rodando
		onlyif => '/usr/bin/docker diff haproxy_mysql', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:haproxy:mysql':
		command => '/usr/bin/docker run -d -p 13306:3306 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/haproxy/mysql.cfg:/etc/haproxy/haproxy.cfg:ro --name="haproxy_mysql" haproxy:latest',
		require => [
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

	exec { 'docker:build:memcached:latest':
		command => '/usr/bin/docker build -t memcached:latest .',
		cwd => '/etc/docker/memcached',
		subscribe => File['etc:docker:memcached:Dockerfile'],
		refreshonly => true,
		timeout => 600,
	}

	# Para contêiner desatualizado
	exec { 'docker:stop:memcached:latest':
		command => '/usr/bin/docker stop memcached_latest',
		subscribe => Exec['docker:build:memcached:latest'],
		refreshonly => true,
		onlyif => '/usr/bin/docker top memcached_latest',
	}

	# Remove contêiner parado
	exec { 'docker:rm:memcached:latest':
		command => '/usr/bin/docker rm memcached_latest',
		require => Exec['docker:stop:memcached:latest'],
		unless => '/usr/bin/docker top memcached_latest', # não está rodando
		onlyif => '/usr/bin/docker diff memcached_latest', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:memcached:latest':
		command => '/usr/bin/docker run -d -p 11211:11211 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw --name="memcached_latest" memcached:latest /usr/bin/memcached -u memcache -m 256',
		require => [
			Exec['docker:rm:memcached:latest'],
		],
		unless => '/usr/bin/docker top memcached_latest', # não está rodando
	}

}

class docker::php-fpm inherits docker {

	file { 'etc:docker:php-fpm':
		path => '/etc/docker/php-fpm',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => File['etc:docker'],
	}

	file { 'etc:docker:php-fpm:Dockerfile':
		path => '/etc/docker/php-fpm/Dockerfile',
		source => 'puppet:///modules/docker/Dockerfile-php-fpm',
		owner => root,
		group => root,
		mode => 0640,
		require => File['etc:docker:php-fpm'],
	}
	
	file { 'etc:docker:php-fpm:php.ini':
		path => '/etc/docker/php-fpm/php.ini',
		source => 'puppet:///modules/docker/php.ini',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	file { 'etc:docker:php-fpm:www.conf':
		path => '/etc/docker/php-fpm/www.conf',
		source => 'puppet:///modules/docker/www.conf',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	file { 'media:wall0:php-fpm':
		path => '/media/wall0/php-fpm',
		ensure => directory,
		owner => root,
		group => www-data,
		mode => 0750,
		require => Exec['mount:wall0'],
	}

	file { 'media:wall0:php-fpm:sessions':
		path => '/media/wall0/php-fpm/sessions',
		ensure => directory,
		owner => root,
		group => www-data,
		mode => 0770,
		require => File['media:wall0:php-fpm'],
	}

	exec { 'docker:build:php-fpm:latest':
		command => '/usr/bin/docker build -t php-fpm:latest .',
		cwd => '/etc/docker/php-fpm',
		subscribe => File['etc:docker:php-fpm:Dockerfile'],
		refreshonly => true,
		timeout => 600,
	}

}

class docker::php-fpm::0 inherits docker::php-fpm {
	
	# Para contêiner desatualizado
	exec { 'docker:stop:php-fpm:latest:0':
		command => '/usr/bin/docker stop php-fpm_latest_0',
		subscribe => [
			Exec['docker:build:php-fpm:latest'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_0',
	}

	# Remove contêiner parado
	exec { 'docker:rm:php-fpm:latest:0':
		command => '/usr/bin/docker rm php-fpm_latest_0',
		require => Exec['docker:stop:php-fpm:latest:0'],
		unless => '/usr/bin/docker top php-fpm_latest_0', # não está rodando
		onlyif => '/usr/bin/docker diff php-fpm_latest_0', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:php-fpm:latest:0':
		command => '/usr/bin/docker run -d -p 8020:80 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/php-fpm/php.ini:/etc/php5/fpm/php.ini:ro -v /etc/docker/php-fpm/www.conf:/etc/php5/fpm/pool.d/www.conf:ro -v /media/wall0/php-fpm/sessions:/var/lib/php5/sessions:rw -v /var/www/html/wiki:/var/www/html/wiki:ro -v /media/wall0/www/images:/var/www/html/wiki/images:rw --name="php-fpm_latest_0" php-fpm:latest',
		require => [
			Exec['docker:rm:php-fpm:latest:0'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['media:wall0:php-fpm:sessions'],
			Exec['git:mediawiki:skin:vector'],
			File['media:wall0:www:images']
		],
		unless => '/usr/bin/docker top php-fpm_latest_0', # não está rodando
	}
	
}

class docker::php-fpm::1 inherits docker::php-fpm {
	
	# Para contêiner desatualizado
	exec { 'docker:stop:php-fpm:latest:1':
		command => '/usr/bin/docker stop php-fpm_latest_1',
		subscribe => [
			Exec['docker:build:php-fpm:latest'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_1',
	}

	# Remove contêiner parado
	exec { 'docker:rm:php-fpm:latest:1':
		command => '/usr/bin/docker rm php-fpm_latest_1',
		require => Exec['docker:stop:php-fpm:latest:1'],
		unless => '/usr/bin/docker top php-fpm_latest_1', # não está rodando
		onlyif => '/usr/bin/docker diff php-fpm_latest_1', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:php-fpm:latest:1':
		command => '/usr/bin/docker run -d -p 8021:80 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/php-fpm/php.ini:/etc/php5/fpm/php.ini:ro -v /etc/docker/php-fpm/www.conf:/etc/php5/fpm/pool.d/www.conf:ro -v /media/wall0/php-fpm/sessions:/var/lib/php5/sessions:rw -v /var/www/html/wiki:/var/www/html/wiki:ro -v /media/wall0/www/images:/var/www/html/wiki/images:rw --name="php-fpm_latest_1" php-fpm:latest',
		require => [
			Exec['docker:rm:php-fpm:latest:0'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['media:wall0:php-fpm:sessions'],
			Exec['git:mediawiki:skin:vector'],
			File['media:wall0:www:images']
		],
		unless => '/usr/bin/docker top php-fpm_latest_1', # não está rodando
	}

}

class docker::nginx inherits docker {

	file { 'etc:docker:nginx':
		path => '/etc/docker/nginx',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => File['etc:docker'],
	}
	
	file { 'etc:docker:nginx:Dockerfile':
		path => '/etc/docker/nginx/Dockerfile',
		source => 'puppet:///modules/docker/Dockerfile-nginx',
		owner => root,
		group => root,
		mode => 0640,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:nginx.conf':
		path => '/etc/docker/nginx/nginx.conf',
		source => 'puppet:///modules/docker/nginx.conf',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:fastcgi_params':
		path => '/etc/docker/nginx/fastcgi_params',
		source => 'puppet:///modules/docker/fastcgi_params',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	exec { 'docker:build:nginx:latest':
		command => '/usr/bin/docker build -t nginx:latest .',
		cwd => '/etc/docker/nginx',
		subscribe => File['etc:docker:nginx:Dockerfile'],
		refreshonly => true,
		timeout => 600,
	}

}

class docker::nginx::0 inherits docker::nginx {
	
	# Para contêiner desatualizado
	exec { 'docker:stop:nginx:latest:0':
		command => '/usr/bin/docker stop nginx_latest_0',
		subscribe => [
			Exec['docker:build:nginx:latest'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_0',
	}

	# Remove contêiner parado
	exec { 'docker:rm:nginx:latest:0':
		command => '/usr/bin/docker rm nginx_latest_0',
		require => Exec['docker:stop:nginx:latest:0'],
		unless => '/usr/bin/docker top nginx_latest_0', # não está rodando
		onlyif => '/usr/bin/docker diff nginx_latest_0', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:nginx:latest:0':
		command => '/usr/bin/docker run -d -p 8010:80 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -v /etc/docker/nginx/fastcgi_params:/etc/nginx/fastcgi_params:ro -v /var/www/html/wiki:/var/www/html/wiki:ro -v /media/wall0/www/images:/var/www/html/wiki/images:rw --name="nginx_latest_0" nginx:latest',
		require => [
			Exec['docker:rm:nginx:latest:0'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			Exec['git:mediawiki:skin:vector'],
			File['media:wall0:www:images']
		],
		unless => '/usr/bin/docker top nginx_latest_0', # não está rodando
	}

}

class docker::nginx::1 inherits docker::nginx {

	# Para contêiner desatualizado
	exec { 'docker:stop:nginx:latest:1':
		command => '/usr/bin/docker stop nginx_latest_1',
		subscribe => [
			Exec['docker:build:nginx:latest'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_1',
	}
	
	# Remove contêiner parado
	exec { 'docker:rm:nginx:latest:1':
		command => '/usr/bin/docker rm nginx_latest_1',
		require => Exec['docker:stop:nginx:latest:1'],
		unless => '/usr/bin/docker top nginx_latest_1', # não está rodando
		onlyif => '/usr/bin/docker diff nginx_latest_1', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:nginx:latest:1':
		command => '/usr/bin/docker run -d -p 8011:80 -v /etc/hosts:/etc/hosts:ro -v /dev/log:/dev/log:rw -v /etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -v /etc/docker/nginx/fastcgi_params:/etc/nginx/fastcgi_params:ro -v /var/www/html/wiki:/var/www/html/wiki:ro -v /media/wall0/www/images:/var/www/html/wiki/images:rw --name="nginx_latest_1" nginx:latest',
		require => [
			Exec['docker:rm:nginx:latest:1'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			Exec['git:mediawiki:skin:vector'],
			File['media:wall0:www:images']
		],
		unless => '/usr/bin/docker top nginx_latest_1', # não está rodando
	}

}
