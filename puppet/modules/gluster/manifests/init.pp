# Gluster init.pp

class gluster::common {

	file { 'fdisk:vdb1':
		path => '/tmp/fdisk',
		source => 'puppet:///modules/gluster/fdisk',
		owner => root,
		group => root,
		mode => 0400,
	}

	exec { 'bootstrap:partition':
		command => '/sbin/fdisk /dev/vdb < /tmp/fdisk',
		creates => '/dev/vdb1',
		require => File['fdisk:vdb1'],
	}

	package { 'xfsprogs':
		ensure => installed,
	}

	exec { 'bootstrap:filesystem':
		command => '/sbin/mkfs.xfs -f -i size=512 /dev/vdb1',
		require => Package['xfsprogs'],
		subscribe => Exec['bootstrap:partition'],
		refreshonly => true,
	}

	package { 'glusterfs-server':
		ensure => installed,
	}

	service { 'glusterfs-server':
		ensure => running,
		enable => true,
		require => Package['glusterfs-server'],
	}

	package { 'glusterfs-client':
		ensure => installed,
		require => Package['glusterfs-server'],
	}

	exec { 'fstab:glusterfs':
		command => '/bin/echo "/dev/vdb1 /glusterfs xfs defaults 0 0" >> /etc/fstab',
		unless => '/bin/grep /glusterfs /etc/fstab',
	}

	file { 'dir:glusterfs':
		path => '/glusterfs',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

	exec { 'mount:glusterfs':
		command => '/bin/mount -a -t xfs',
		require => [
			Exec['bootstrap:filesystem'],
			Exec['fstab:glusterfs'],
			File['dir:glusterfs'],
		],
	}

	file { 'dir:glusterfs:wall0':
		path => '/glusterfs/wall0',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
		require => Exec['mount:glusterfs'],
	}

	exec { 'fstab:wall0':
		command => '/bin/echo "localhost:wall0 /media/wall0 glusterfs defaults 0 0" >> /etc/fstab',
		unless => '/bin/grep /media/wall0 /etc/fstab',
	}

	file { 'dir:media:wall0':
		path => '/media/wall0',
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

	exec { 'mount:wall0':
		command => '/bin/mount -a -t glusterfs',
		require => [
			Exec['fstab:wall0'],
			File['dir:media:wall0'],
		],
		onlyif => '/usr/sbin/gluster volume info wall0 | grep Started',
	}

}

class gluster::bootstrap inherits gluster::common {

	exec { 'gluster:probe:wiki0':
		command => '/usr/sbin/gluster peer probe wiki0',
		unless => '/usr/sbin/gluster peer status | grep wiki0',
		require => Package['glusterfs-client'],
	}

	exec { 'gluster:probe:wiki1':
		command => '/usr/sbin/gluster peer probe wiki1',
		unless => '/usr/sbin/gluster peer status | grep wiki1',
		require => Package['glusterfs-client'],
	}

	exec { 'gluster:volume:create:wall0':
	command => '/usr/sbin/gluster volume create wall0 replica 3 transport tcp puppet:/glusterfs/wall0 wiki0:/glusterfs/wall0 wiki1:/glusterfs/wall0',
		require => [
			File['dir:glusterfs:wall0'],
			Exec['gluster:probe:wiki0'],
			Exec['gluster:probe:wiki1'],
		],
		creates => '/var/lib/glusterd/vols/wall0/info',
	}

	exec { 'gluster:volume:start:wall0':
		command => '/usr/sbin/gluster volume start wall0',
		require => Exec['gluster:volume:create:wall0'],
		unless => '/usr/sbin/gluster volume info wall0 | grep Started',
	}

}
