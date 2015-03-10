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
		command => '/usr/bin/git clone --depth 1 https://git.wikimedia.org/git/mediawiki/core.git -b 1.24.1 /var/www/html/wiki',
		creates => '/var/www/html/wiki/.git',
	}

}