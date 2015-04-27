class www {

	file { 'var:www':
		path => '/var/www',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

	file { 'var:www:html':
		path => '/var/www/html',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

}

class www::mediawiki inherits www {

	exec { 'git:mediawiki':
		command => '/usr/bin/git clone --depth 1 https://git.wikimedia.org/git/mediawiki/core.git -b REL1_24 /var/www/html/wiki',
		creates => '/var/www/html/wiki/.git',
	}

	exec { 'git:mediawiki:skin:vector':
		command => '/usr/bin/git clone --depth 1 https://git.wikimedia.org/git/mediawiki/skins/Vector.git -b REL1_24 /var/www/html/wiki/skins/Vector',
		creates => '/var/www/html/wiki/skins/Vector/.git',
		require => Exec['git:mediawiki'],
	}

	file { 'mediawiki.sql':
		path => '/etc/mysql/mediawiki.sql',
		source => 'puppet:///modules/www/mediawiki.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:mediawiki':
		command => '/usr/bin/mysql --user=root --password=root < /etc/mysql/mediawiki.sql',
		require => [
			Service['mysql'],
			File['mediawiki.sql'],
		],
		creates => '/var/lib/mysql/mediawiki/',
	}

	file { 'media:wall0:www':
		path => '/media/wall0/www',
		ensure => directory,
		owner => root,
		group => www-data,
		mode => 0750,
		require => Exec['mount:wall0'],
	}

	file { 'media:wall0:www:images':
		path => '/media/wall0/www/images',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0770,
		require => File['media:wall0:www'],
	}

	# Liberar este recurso SOMENTE depois de instalado o Mediawiki via web.
	# Poderia ser automatizado, mas como gera alguns valores próprios,
	# como por exemplo timestamp das modificações e chaves secretas,
	# convém realizar o processo na forma interativa.
	#file { 'LocalSettings.php':
	#	path => '/var/www/html/wiki/LocalSettings.php',
	#	source => 'puppet:///modules/www/LocalSettings.php',
	#	owner => root,
	#	group => www-data,
	#	mode => 0440,
	#	require => [
	#		Exec['git:mediawiki:skin:vector'],
	#		Exec['mysql:mediawiki'],
	#		File['media:wall0:www:images'],
	#	],
	#}

	exec { 'git:SimpleSamlAuth':
		command => '/usr/bin/git clone https://github.com/yorn/mwSimpleSamlAuth.git -b v0.4 /var/www/html/wiki/extensions/SimpleSamlAuth',
		creates => '/var/www/html/wiki/extensions/SimpleSamlAuth',
		require => Exec['git:mediawiki'],
	}
	
	file { 'link:simplesamlphp':
		path => '/var/www/html/simplesamlphp',
		ensure => link,
		target => '/usr/share/simplesamlphp/www',
		owner => root,
		group => root,
		mode => 0755,
		require => Exec['git:mediawiki'],
	}

}
