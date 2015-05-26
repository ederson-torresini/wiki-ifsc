<?php
$CONFIG = array (
	'overwritehost' => 'owncloud.openstack.sj.ifsc.edu.br',
	'overwriteprotocol' => 'https',
	'overwrite.cli.url' => 'https://owncloud.openstack.sj.ifsc.edu.br/owncloud',
	'trusted_domains' => array (
		0 => 'owncloud.openstack.sj.ifsc.edu.br',
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
			0 => 'wiki0',
			1 => 11211,
		),
		1 => array (
			0 => 'wiki1',
			1 => 11211,
		),
	),
	'installed' => true,
	'instanceid' => 'PHPSESSID',
	'passwordsalt' => 'owncloud',
	'secret' => 'owcloud',
	'version' => '8.0.3.4',
);
