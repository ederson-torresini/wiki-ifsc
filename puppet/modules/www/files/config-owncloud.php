<?php
$CONFIG = array (
	'overwritehost' => 'www.openstack.sj.ifsc.edu.br',
	'overwriteprotocol' => 'https',
	'overwrite.cli.url' => 'https://www.openstack.sj.ifsc.edu.br/owncloud',
	'overwritewebroot' => '/owncloud',
	'trusted_domains' => array (
		0 => 'www.openstack.sj.ifsc.edu.br',
	),
	'datadirectory' => '/var/www/html/owncloud/data',
	'appstoreenabled' => false,
	'apps_paths' => array (
		0 => array (
			'path' => '/var/www/html/owncloud/apps',
			'url' => '/apps',
			'writable' => false,
		),
		1 => array (
			'path' => '/var/www/html/owncloud/apps+',
			'url' => '/apps+',
			'writable' => false,
		),
	),
	'dbtype' => 'mysql',
	'dbname' => 'owncloud',
	'dbhost' => 'mysql:13306',
	'dbtableprefix' => 'oc_',
	'dbuser' => 'owncloud',
	'dbpassword' => 'owncloud',
	'memcached_servers' => array (
		0 => array (
			0 => 'web0',
			1 => 11211,
		),
		1 => array (
			0 => 'web1',
			1 => 11211,
		),
	),
	'installed' => true,
	'instanceid' => 'owncloud',
	'passwordsalt' => 'owncloud',
	'secret' => 'owcloud',
	'version' => '8.0.4.2',
	'log_type' => 'syslog',
    'logfile' => '',
	'logtimezone' => 'America/Sao_Paulo',
);
