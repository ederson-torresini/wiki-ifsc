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

	file { 'link:simplesamlphp':
		path => '/var/www/html/simplesamlphp',
		ensure => link,
		target => '/usr/share/simplesamlphp/www',
		owner => root,
		group => root,
		mode => 0755,
		require => File['var:www:html'],
	}

	file { 'media:wall0:www':
		path => '/media/wall0/www',
		ensure => directory,
		owner => root,
		group => www-data,
		mode => 0750,
		require => Exec['mount:wall0'],
	}

}

class www::mediawiki inherits www {

	$VERSAO = 'REL1_24'

	exec { 'git:mediawiki':
		command => "/usr/bin/git clone --depth 1 https://git.wikimedia.org/git/mediawiki/core.git -b $VERSAO /var/www/html/wiki",
		creates => '/var/www/html/wiki/.git',
	}

	exec { 'git:mediawiki:skin:vector':
		command => "/usr/bin/git clone --depth 1 https://git.wikimedia.org/git/mediawiki/skins/Vector.git -b $VERSAO /var/www/html/wiki/skins/Vector",
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

	file { 'media:wall0:www:wiki':
		path => '/media/wall0/www/wiki',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0770,
		require => File['media:wall0:www'],
	}

	file { 'media:wall0:www:wiki:images':
		path => '/media/wall0/www/wiki/images',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0770,
		require => File['media:wall0:www:wiki'],
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
	#		File['media:wall0:www:wiki:images'],
	#	],
	#}

	exec { 'git:SimpleSamlAuth':
		command => '/usr/bin/git clone https://github.com/yorn/mwSimpleSamlAuth.git -b v0.4 /var/www/html/wiki/extensions/SimpleSamlAuth',
		creates => '/var/www/html/wiki/extensions/SimpleSamlAuth',
		require => [
			File['link:simplesamlphp'],
			Exec['git:mediawiki'],
		],
	}

}

class www::owncloud inherits www {

	$VERSAO = 'v8.0.3'

	exec { 'git:owncloud:core':
		command => "/usr/bin/git clone --depth 1 https://github.com/owncloud/core.git -b $VERSAO /var/www/html/owncloud",
		creates => '/var/www/html/owncloud/.git',
	}

	exec { 'git:owncloud:3rdparty':
		command => "/usr/bin/git clone --depth 1 https://github.com/owncloud/3rdparty.git -b $VERSAO /var/www/html/owncloud/3rdparty",
		creates => '/var/www/html/owncloud/3rdparty/.git',
		require => Exec['git:owncloud:core'],
	}

	exec { 'git:owncloud:apps+':
		command => "/usr/bin/git clone --depth 1 https://github.com/owncloud/apps.git -b $VERSAO /var/www/html/owncloud/apps+",
		creates => '/var/www/html/owncloud/apps+/.git',
		require => Exec['git:owncloud:core'],
	}

	# Correção de código para evitar problemas com segurança (CSP)
	file { 'git:owncloud:apps+:utils.js':
		path => '/var/www/html/owncloud/apps+/user_saml/js/utils.js',
		source => 'puppet:///modules/www/utils.js',
		owner => www-data,
		group => www-data,
		mode => 0440,
		require => Exec['git:owncloud:apps+'],
	}

	file { 'media:wall0:www:owncloud':
		path => '/media/wall0/www/owncloud',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0750,
		require => File['media:wall0:www'],
	}

	file { 'media:wall0:www:owncloud:config':
		path => '/media/wall0/www/owncloud/config',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0750,
		require => File['media:wall0:www:owncloud'],
	}

	# Apenas para rodar as máquinas Docker (montagem do diretório com o recurso a seguir).
	file { 'git:owncloud:data':
		path => '/var/www/html/owncloud/data',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0750,
		require => Exec['git:owncloud:core'],
	}

	file { 'media:wall0:www:owncloud:data':
		path => '/media/wall0/www/owncloud/data',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0750,
		require => File['media:wall0:www:owncloud'],
	}

	file { 'media:wall0:www:owncloud:data:.ocdata':
		path => '/media/wall0/www/owncloud/data/.ocdata',
		ensure => file,
		owner => www-data,
		group => www-data,
		mode => 0640,
		require => File['media:wall0:www:owncloud:data'],
	}

	file { 'media:wall0:www:owncloud:themes':
		path => '/media/wall0/www/owncloud/themes',
		ensure => directory,
		owner => www-data,
		group => www-data,
		mode => 0750,
		require => File['media:wall0:www:owncloud'],
	}

	# Apenas para rodar as máquinas Docker (montagem do arquivo).
	file { 'git:owncloud:post.js':
		path => '/var/www/html/owncloud/post.js',
		ensure => file,
		owner => www-data,
		group => www-data,
		mode => 0640,
		require => Exec['git:owncloud:core'],
	}


	file { 'owncloud.sql':
		path => '/etc/mysql/owncloud.sql',
		source => 'puppet:///modules/www/owncloud.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => Package['mysql-wsrep-server'],
	}

	exec { 'mysql:owncloud':
		command => '/usr/bin/mysql --user=root --password=root < /etc/mysql/owncloud.sql',
		require => [
			Service['mysql'],
			File['owncloud.sql'],
		],
		creates => '/var/lib/mysql/owncloud/',
	}

	file { 'owncloud-tables.sql':
		path => '/etc/mysql/owncloud-tables.sql',
		source => 'puppet:///modules/www/owncloud-tables.sql',
		owner => root,
		group => mysql,
		mode => 0640,
		require => [
			Package['mysql-wsrep-server'],
			Exec['mysql:owncloud'],
		],
	}

	exec { 'mysql:owncloud-tables':
		command => '/usr/bin/mysql --user=root --password=root owncloud < /etc/mysql/owncloud-tables.sql',
		require => [
			Service['mysql'],
			File['owncloud-tables.sql'],
		],
		creates => '/var/lib/mysql/owncloud/oc_users.frm',
	}

	file { 'owncloud:config.php':
		path => '/media/wall0/www/owncloud/config/config.php',
		source => 'puppet:///modules/www/config-owncloud.php',
		owner => www-data,
		group => www-data,
		mode => 0640,
		require => [
			Exec['git:owncloud:core'],
			Exec['git:owncloud:3rdparty'],
			Exec['git:owncloud:apps+'],
			File['git:owncloud:apps+:utils.js'],
			File['media:wall0:www:owncloud:config'],
			File['git:owncloud:data'],
			File['media:wall0:www:owncloud:data'],
			File['media:wall0:www:owncloud:data:.ocdata'],
			File['media:wall0:www:owncloud:themes'],
			Exec['mysql:owncloud'],
			Exec['mysql:owncloud-tables'],
		],
	}

}
