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

	$hosts = "--add-host=puppet:10.0.0.135 \
		--add-host=syslog:10.0.0.135 \
		--add-host=web0:10.0.0.136 \
		--add-host=web1:10.0.0.137 \
		--add-host=mysql:10.0.0.137 \
		--add-host=puppet-ext:192.168.1.158 \
		--add-host=web0-ext:192.168.1.159 \
		--add-host=web1-ext:192.168.1.160"
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

	exec { 'docker:build:ifsc/haproxy:latest':
		command => '/usr/bin/docker build -t ifsc/haproxy:latest .',
		cwd => '/etc/docker/haproxy',
		require => File['etc:docker:haproxy:Dockerfile'],
		unless => '/usr/bin/docker images | grep -q ifsc/haproxy',
		timeout => 1800,
	}

	file { 'docker:haproxy:haproxy.cfg':
		path => '/etc/docker/haproxy/haproxy.cfg',
		source => 'puppet:///modules/docker/haproxy.cfg',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:haproxy'],
	}

	# O arquivo https.pem foi gerado com o comando:
	# openssl req -new -x509 -nodes -days 365 -keyout https.pem -out https.pem
	file { 'docker:haproxy:https.pem':
		path => '/etc/docker/haproxy/https.pem',
		source => 'puppet:///modules/docker/https.pem',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:haproxy'],
	}

	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/haproxy:latest':
		command => '/usr/bin/docker stop haproxy_latest',
		subscribe => [
			Exec['docker:build:ifsc/haproxy:latest'],
			File['docker:haproxy:haproxy.cfg'],
			File['docker:haproxy:https.pem'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top haproxy_latest',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/haproxy:latest':
		command => '/usr/bin/docker rm haproxy_latest',
		require => Exec['docker:stop:ifsc/haproxy:latest'],
		unless => '/usr/bin/docker top haproxy_latest', # não está rodando
		onlyif => '/usr/bin/docker diff haproxy_latest', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/haproxy:latest':
		command => "/usr/bin/docker run -d -p 80:80 -p 443:443 -p 13306:3306 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /etc/docker/haproxy/haproxy.cfg:/etc/haproxy/haproxy.cfg:ro \
			-v /etc/docker/haproxy/https.pem:/etc/ssl/certs/https.pem:ro \
			--name=haproxy_latest ifsc/haproxy:latest",
		require => [
			Exec['docker:build:ifsc/haproxy:latest'],
			Exec['docker:rm:ifsc/haproxy:latest'],
			File['docker:haproxy:haproxy.cfg'],
			File['docker:haproxy:https.pem'],
		],
		unless => '/usr/bin/docker top haproxy_latest', # não está rodando
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

	exec { 'docker:build:ifsc/memcached:latest':
		command => '/usr/bin/docker build -t ifsc/memcached:latest .',
		cwd => '/etc/docker/memcached',
		require => File['etc:docker:memcached:Dockerfile'],
		unless => '/usr/bin/docker images | grep -q ifsc/memcached',
		timeout => 1800,
	}

	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/memcached:latest':
		command => '/usr/bin/docker stop memcached_latest',
		subscribe => Exec['docker:build:ifsc/memcached:latest'],
		refreshonly => true,
		onlyif => '/usr/bin/docker top memcached_latest',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/memcached:latest':
		command => '/usr/bin/docker rm memcached_latest',
		require => Exec['docker:stop:ifsc/memcached:latest'],
		unless => '/usr/bin/docker top memcached_latest', # não está rodando
		onlyif => '/usr/bin/docker diff memcached_latest', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/memcached:latest':
		command => "/usr/bin/docker run -d -p 11211:11211 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			--name=memcached_latest ifsc/memcached:latest \
			/usr/bin/memcached -u memcache -m 256",
		require => [
			Exec['docker:build:ifsc/memcached:latest'],
			Exec['docker:rm:ifsc/memcached:latest'],
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
	
	file { 'etc:docker:php-fpm:php-fpm.conf':
		path => '/etc/docker/php-fpm/php-fpm.conf',
		source => 'puppet:///modules/docker/php-fpm.conf',
		owner => root,
		group => root,
		mode => 0644,
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

	file { 'etc:docker:php-fpm:config.php':
		path => '/etc/docker/php-fpm/config.php',
		source => 'puppet:///modules/docker/config.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	file { 'etc:docker:php-fpm:authsources.php':
		path => '/etc/docker/php-fpm/authsources.php',
		source => 'puppet:///modules/docker/authsources.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	file { 'etc:docker:php-fpm:saml20-idp-remote.php':
		path => '/etc/docker/php-fpm/saml20-idp-remote.php',
		source => 'puppet:///modules/docker/saml20-idp-remote.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	file { 'etc:docker:php-fpm:post.php':
		path => '/etc/docker/php-fpm/post.php',
		source => 'puppet:///modules/docker/post.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	# Os 2 próximos arquivos foram gerados com o comando:
	# openssl req -new -x509 -nodes -days 365 -keyout saml.key -out saml.crt
	file { 'etc:docker:php-fpm:saml.key':
		path => '/etc/docker/php-fpm/saml.key',
		source => 'puppet:///modules/docker/saml.key',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:php-fpm'],
	}

	# Ver comentário do recurso anterior
	file { 'etc:docker:php-fpm:saml.crt':
		path => '/etc/docker/php-fpm/saml.crt',
		source => 'puppet:///modules/docker/saml.crt',
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
		owner => www-data,
		group => www-data,
		mode => 0770,
		require => File['media:wall0:php-fpm'],
	}

	exec { 'docker:build:ifsc/php-fpm:latest':
		command => '/usr/bin/docker build -t ifsc/php-fpm:latest .',
		cwd => '/etc/docker/php-fpm',
		require => File['etc:docker:php-fpm:Dockerfile'],
		unless => '/usr/bin/docker images | grep -q ifsc/php-fpm',
		timeout => 1800,
	}

}

class docker::php-fpm::limpeza {

	file { 'cron:sessions':
		path => '/etc/cron.hourly/sessions',
		source => 'puppet:///modules/docker/sessions',
		owner => root,
		group => root,
		mode => 0754,
		require => Exec['mount:wall0'],
	}

}

class docker::php-fpm::0 inherits docker::php-fpm {
	
	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/php-fpm:latest:0':
		command => '/usr/bin/docker stop php-fpm_latest_0',
		subscribe => [
			Exec['docker:build:ifsc/php-fpm:latest'],
			File['etc:docker:php-fpm:php-fpm.conf'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['etc:docker:php-fpm:config.php'],
			File['etc:docker:php-fpm:authsources.php'],
			File['etc:docker:php-fpm:saml20-idp-remote.php'],
			File['etc:docker:php-fpm:post.php'],
			File['etc:docker:php-fpm:saml.key'],
			File['etc:docker:php-fpm:saml.crt'],
			File['media:wall0:php-fpm:sessions'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top php-fpm_latest_0',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/php-fpm:latest:0':
		command => '/usr/bin/docker rm php-fpm_latest_0',
		require => Exec['docker:stop:ifsc/php-fpm:latest:0'],
		unless => '/usr/bin/docker top php-fpm_latest_0', # não está rodando
		onlyif => '/usr/bin/docker diff php-fpm_latest_0', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/php-fpm:latest:0':
		command => "/usr/bin/docker run -d -p 8020:80 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /dev/urandom:/dev/urandom:rw \
			-v /etc/docker/php-fpm/php-fpm.conf:/etc/php5/fpm/php-fpm.conf:ro \
			-v /etc/docker/php-fpm/php.ini:/etc/php5/fpm/php.ini:ro \
			-v /etc/docker/php-fpm/www.conf:/etc/php5/fpm/pool.d/www.conf:ro \
			-v /etc/docker/php-fpm/config.php:/etc/simplesamlphp/config.php:ro \
			-v /etc/docker/php-fpm/authsources.php:/etc/simplesamlphp/authsources.php:ro \
			-v /etc/docker/php-fpm/saml20-idp-remote.php:/etc/simplesamlphp/metadata/saml20-idp-remote.php:ro \
			-v /etc/docker/php-fpm/post.php:/usr/share/simplesamlphp/templates/post.php:ro \
			-v /etc/docker/php-fpm/saml.key:/etc/ssl/certs/saml.key:ro \
			-v /etc/docker/php-fpm/saml.crt:/etc/ssl/certs/saml.crt:ro \
			-v /media/wall0/php-fpm/sessions:/var/lib/php5/sessions:rw \
			-v /var/www/html:/var/www/html:ro \
			-v /media/wall0/www/wiki/images:/var/www/html/wiki/images:rw \
			-v /media/wall0/www/owncloud/config:/var/www/html/owncloud/config:rw \
			-v /media/wall0/www/owncloud/data:/var/www/html/owncloud/data:rw \
			-v /media/wall0/www/owncloud/themes:/var/www/html/owncloud/themes:rw \
			--name=php-fpm_latest_0 ifsc/php-fpm:latest",
		require => [
			Exec['docker:build:ifsc/php-fpm:latest'],
			Exec['docker:rm:ifsc/php-fpm:latest:0'],
			File['etc:docker:php-fpm:php-fpm.conf'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['etc:docker:php-fpm:config.php'],
			File['etc:docker:php-fpm:authsources.php'],
			File['etc:docker:php-fpm:saml20-idp-remote.php'],
			File['etc:docker:php-fpm:post.php'],
			File['etc:docker:php-fpm:saml.key'],
			File['etc:docker:php-fpm:saml.crt'],
			File['media:wall0:php-fpm:sessions'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		unless => '/usr/bin/docker top php-fpm_latest_0', # não está rodando
	}
	
}

class docker::php-fpm::1 inherits docker::php-fpm {
	
	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/php-fpm:latest:1':
		command => '/usr/bin/docker stop php-fpm_latest_1',
		subscribe => [
			Exec['docker:build:ifsc/php-fpm:latest'],
			File['etc:docker:php-fpm:php-fpm.conf'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['etc:docker:php-fpm:config.php'],
			File['etc:docker:php-fpm:authsources.php'],
			File['etc:docker:php-fpm:saml20-idp-remote.php'],
			File['etc:docker:php-fpm:post.php'],
			File['etc:docker:php-fpm:saml.key'],
			File['etc:docker:php-fpm:saml.crt'],
			File['media:wall0:php-fpm:sessions'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top php-fpm_latest_1',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/php-fpm:latest:1':
		command => '/usr/bin/docker rm php-fpm_latest_1',
		require => Exec['docker:stop:ifsc/php-fpm:latest:1'],
		unless => '/usr/bin/docker top php-fpm_latest_1', # não está rodando
		onlyif => '/usr/bin/docker diff php-fpm_latest_1', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/php-fpm:latest:1':
		command => "/usr/bin/docker run -d -p 8021:80 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /dev/urandom:/dev/urandom:rw \
			-v /etc/docker/php-fpm/php-fpm.conf:/etc/php5/fpm/php-fpm.conf:ro \
			-v /etc/docker/php-fpm/php.ini:/etc/php5/fpm/php.ini:ro \
			-v /etc/docker/php-fpm/www.conf:/etc/php5/fpm/pool.d/www.conf:ro \
			-v /etc/docker/php-fpm/config.php:/etc/simplesamlphp/config.php:ro \
			-v /etc/docker/php-fpm/authsources.php:/etc/simplesamlphp/authsources.php:ro \
			-v /etc/docker/php-fpm/saml20-idp-remote.php:/etc/simplesamlphp/metadata/saml20-idp-remote.php:ro \
			-v /etc/docker/php-fpm/post.php:/usr/share/simplesamlphp/templates/post.php:ro \
			-v /etc/docker/php-fpm/saml.key:/etc/ssl/certs/saml.key:ro \
			-v /etc/docker/php-fpm/saml.crt:/etc/ssl/certs/saml.crt:ro \
			-v /media/wall0/php-fpm/sessions:/var/lib/php5/sessions:rw \
			-v /var/www/html:/var/www/html:ro \
			-v /media/wall0/www/wiki/images:/var/www/html/wiki/images:rw \
			-v /media/wall0/www/owncloud/config:/var/www/html/owncloud/config:rw \
			-v /media/wall0/www/owncloud/data:/var/www/html/owncloud/data:rw \
			-v /media/wall0/www/owncloud/themes:/var/www/html/owncloud/themes:rw \
			--name=php-fpm_latest_1 ifsc/php-fpm:latest",
		require => [
			Exec['docker:build:ifsc/php-fpm:latest'],
			Exec['docker:rm:ifsc/php-fpm:latest:1'],
			File['etc:docker:php-fpm:php-fpm.conf'],
			File['etc:docker:php-fpm:php.ini'],
			File['etc:docker:php-fpm:www.conf'],
			File['etc:docker:php-fpm:config.php'],
			File['etc:docker:php-fpm:authsources.php'],
			File['etc:docker:php-fpm:saml20-idp-remote.php'],
			File['etc:docker:php-fpm:post.php'],
			File['etc:docker:php-fpm:saml.key'],
			File['etc:docker:php-fpm:saml.crt'],
			File['media:wall0:php-fpm:sessions'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
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

	file { 'etc:docker:nginx:config.php':
		path => '/etc/docker/nginx/config.php',
		source => 'puppet:///modules/docker/config.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:authsources.php':
		path => '/etc/docker/nginx/authsources.php',
		source => 'puppet:///modules/docker/authsources.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:saml20-idp-remote.php':
		path => '/etc/docker/nginx/saml20-idp-remote.php',
		source => 'puppet:///modules/docker/saml20-idp-remote.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:post.php':
		path => '/etc/docker/nginx/post.php',
		source => 'puppet:///modules/docker/post.php',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:saml.key':
		path => '/etc/docker/nginx/saml.key',
		source => 'puppet:///modules/docker/saml.key',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	file { 'etc:docker:nginx:saml.crt':
		path => '/etc/docker/nginx/saml.crt',
		source => 'puppet:///modules/docker/saml.crt',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:nginx'],
	}

	exec { 'docker:build:ifsc/nginx:latest':
		command => '/usr/bin/docker build -t ifsc/nginx:latest .',
		cwd => '/etc/docker/nginx',
		require => File['etc:docker:nginx:Dockerfile'],
		unless => '/usr/bin/docker images | grep -q ifsc/nginx',
		timeout => 1800,
	}

}

class docker::nginx::0 inherits docker::nginx {

	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/nginx:latest:0':
		command => '/usr/bin/docker stop nginx_latest_0',
		subscribe => [
			Exec['docker:build:ifsc/nginx:latest'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			File['etc:docker:nginx:config.php'],
			File['etc:docker:nginx:authsources.php'],
			File['etc:docker:nginx:saml20-idp-remote.php'],
			File['etc:docker:nginx:post.php'],
			File['etc:docker:nginx:saml.key'],
			File['etc:docker:nginx:saml.crt'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_0',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/nginx:latest:0':
		command => '/usr/bin/docker rm nginx_latest_0',
		require => Exec['docker:stop:ifsc/nginx:latest:0'],
		unless => '/usr/bin/docker top nginx_latest_0', # não está rodando
		onlyif => '/usr/bin/docker diff nginx_latest_0', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/nginx:latest:0':
		command => "/usr/bin/docker run -d -p 8010:80 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /dev/urandom:/dev/urandom:rw \
			-v /etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
			-v /etc/docker/nginx/fastcgi_params:/etc/nginx/fastcgi_params:ro \
			-v /etc/docker/nginx/config.php:/etc/simplesamlphp/config.php:ro \
			-v /etc/docker/nginx/authsources.php:/etc/simplesamlphp/authsources.php:ro \
			-v /etc/docker/nginx/saml20-idp-remote.php:/etc/simplesamlphp/metadata/saml20-idp-remote.php:ro \
			-v /etc/docker/nginx/post.php:/usr/share/simplesamlphp/templates/post.php:ro \
			-v /etc/docker/nginx/saml.key:/etc/ssl/certs/saml.key:ro \
			-v /etc/docker/nginx/saml.crt:/etc/ssl/certs/saml.crt:ro \
			-v /var/www/html:/var/www/html:ro \
			-v /media/wall0/www/wiki/images:/var/www/html/wiki/images:rw \
			-v /media/wall0/www/owncloud/config:/var/www/html/owncloud/config:rw \
			-v /media/wall0/www/owncloud/data:/var/www/html/owncloud/data:rw \
			-v /media/wall0/www/owncloud/themes:/var/www/html/owncloud/themes:rw \
			--name=nginx_latest_0 ifsc/nginx:latest",
		require => [
			Exec['docker:build:ifsc/nginx:latest'],
			Exec['docker:rm:ifsc/nginx:latest:0'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			File['etc:docker:nginx:config.php'],
			File['etc:docker:nginx:authsources.php'],
			File['etc:docker:nginx:saml20-idp-remote.php'],
			File['etc:docker:nginx:post.php'],
			File['etc:docker:nginx:saml.key'],
			File['etc:docker:nginx:saml.crt'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		unless => '/usr/bin/docker top nginx_latest_0', # não está rodando
	}

}

class docker::nginx::1 inherits docker::nginx {

	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/nginx:latest:1':
		command => '/usr/bin/docker stop nginx_latest_1',
		subscribe => [
			Exec['docker:build:ifsc/nginx:latest'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			File['etc:docker:nginx:config.php'],
			File['etc:docker:nginx:authsources.php'],
			File['etc:docker:nginx:saml20-idp-remote.php'],
			File['etc:docker:nginx:post.php'],
			File['etc:docker:nginx:saml.key'],
			File['etc:docker:nginx:saml.crt'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top nginx_latest_1',
	}
	
	# Remove contêiner parado
	exec { 'docker:rm:ifsc/nginx:latest:1':
		command => '/usr/bin/docker rm nginx_latest_1',
		require => Exec['docker:stop:ifsc/nginx:latest:1'],
		unless => '/usr/bin/docker top nginx_latest_1', # não está rodando
		onlyif => '/usr/bin/docker diff nginx_latest_1', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/nginx:latest:1':
		command => "/usr/bin/docker run -d -p 8011:80 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /dev/urandom:/dev/urandom:rw \
			-v /etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
			-v /etc/docker/nginx/fastcgi_params:/etc/nginx/fastcgi_params:ro \
			-v /etc/docker/nginx/config.php:/etc/simplesamlphp/config.php:ro \
			-v /etc/docker/nginx/authsources.php:/etc/simplesamlphp/authsources.php:ro \
			-v /etc/docker/nginx/saml20-idp-remote.php:/etc/simplesamlphp/metadata/saml20-idp-remote.php:ro \
			-v /etc/docker/nginx/post.php:/usr/share/simplesamlphp/templates/post.php:ro \
			-v /etc/docker/nginx/saml.key:/etc/ssl/certs/saml.key:ro \
			-v /etc/docker/nginx/saml.crt:/etc/ssl/certs/saml.crt:ro \
			-v /var/www/html:/var/www/html:ro \
			-v /media/wall0/www/wiki/images:/var/www/html/wiki/images:rw \
			-v /media/wall0/www/owncloud/config:/var/www/html/owncloud/config:rw \
			-v /media/wall0/www/owncloud/data:/var/www/html/owncloud/data:rw \
			-v /media/wall0/www/owncloud/themes:/var/www/html/owncloud/themes:rw \
			--name=nginx_latest_1 ifsc/nginx:latest",
		require => [
			Exec['docker:build:ifsc/nginx:latest'],
			Exec['docker:rm:ifsc/nginx:latest:1'],
			File['etc:docker:nginx:nginx.conf'],
			File['etc:docker:nginx:fastcgi_params'],
			File['etc:docker:nginx:config.php'],
			File['etc:docker:nginx:authsources.php'],
			File['etc:docker:nginx:saml20-idp-remote.php'],
			File['etc:docker:nginx:post.php'],
			File['etc:docker:nginx:saml.key'],
			File['etc:docker:nginx:saml.crt'],
			File['var:www:html'],
			File['media:wall0:www:wiki:images'],
			File['media:wall0:www:owncloud:config'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:themes'],
		],
		unless => '/usr/bin/docker top nginx_latest_1', # não está rodando
	}

}

class docker::varnish inherits docker {

	file { 'etc:docker:varnish':
		path => '/etc/docker/varnish',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0750,
		require => File['etc:docker'],
	}

	file { 'etc:docker:varnish:Dockerfile':
		path => '/etc/docker/varnish/Dockerfile',
		source => 'puppet:///modules/docker/Dockerfile-varnish',
		owner => root,
		group => root,
		mode => 0640,
		require => File['etc:docker:varnish'],
	}

	exec { 'docker:build:ifsc/varnish:latest':
		command => '/usr/bin/docker build -t ifsc/varnish:latest .',
		cwd => '/etc/docker/varnish',
		require => File['etc:docker:varnish:Dockerfile'],
		unless => '/usr/bin/docker images | grep -q ifsc/varnish',
		timeout => 1800,
	}

	file { 'docker:ifsc/varnish:latest:default.vcl':
		path => '/etc/docker/varnish/default.vcl',
		source => 'puppet:///modules/docker/default.vcl',
		owner => root,
		group => root,
		mode => 0644,
		require => File['etc:docker:varnish'],
	}

	# Para contêiner desatualizado
	exec { 'docker:stop:ifsc/varnish:latest':
		command => '/usr/bin/docker stop varnish_latest',
		subscribe => [
			Exec['docker:build:ifsc/varnish:latest'],
			File['docker:ifsc/varnish:latest:default.vcl'],
		],
		refreshonly => true,
		onlyif => '/usr/bin/docker top varnish_latest',
	}

	# Remove contêiner parado
	exec { 'docker:rm:ifsc/varnish:latest':
		command => '/usr/bin/docker rm varnish_latest',
		require => Exec['docker:stop:ifsc/varnish:latest'],
		unless => '/usr/bin/docker top varnish_latest', # não está rodando
		onlyif => '/usr/bin/docker diff varnish_latest', # contêiner existe (mesmo parado)
	}

	# Inicia um novo contêiner
	exec { 'docker:run:ifsc/varnish:latest':
		command => "/usr/bin/docker run -d -p 8000:80 \
			$hosts \
			-v /dev/log:/dev/log:rw \
			-v /etc/docker/varnish/default.vcl:/etc/varnish/default.vcl:ro \
			--name=varnish_latest ifsc/varnish:latest \
			/usr/sbin/varnishd -F -a :80 -s malloc,256M -f /etc/varnish/default.vcl",
		require => [
			Exec['docker:build:ifsc/varnish:latest'],
			Exec['docker:rm:ifsc/varnish:latest'],
			File['docker:ifsc/varnish:latest:default.vcl'],
		],
		unless => '/usr/bin/docker top varnish_latest', # não está rodando
	}

}
