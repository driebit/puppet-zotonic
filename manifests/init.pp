# Installs Zotonic
# See also https://github.com/zotonic/zotonic/blob/master/zotonic_install
class zotonic
(
  $erlang_package      = 'erlang',
  $imagemagick_package = '',
  $password            = '',
  $listen_port         = '8000',
  $dir                 = '/opt/zotonic',
  $version             = 'release-0.9.4',
  $user                = 'zotonic',
) {
  include postgresql::server

  # Create zotonic user if necessary
  if !defined(User[$user]) {
    user { $user:
      ensure => present,
    }
  }

  if $erlang_package {
    if !defined(Package[$erlang_package]) {
      case $::operatingsystem {
        'centos': {
          # CentOS needs the EPEL repo for the Erlang package
          if !defined(Class['yum::repo::epel']) {
            class { 'yum::repo::epel':
              before => Package[$erlang_package]
            }
          }
        }
      }

      package { $erlang_package:
        ensure => present
      }
    }
  }

  if $imagemagick_package {
    $imagemagick_package_name = $imagemagick_package
  } else {
    case $::operatingsystem {
      'centos': { $imagemagick_package_name = 'ImageMagick' }
      default:  { $imagemagick_package_name = 'imagemagick' }
    }
  }

  if !defined(Package[$imagemagick_package_name]) {
    package { $imagemagick_package_name:
      ensure => present
    }
  }

  case $::operatingsystem {
    'ubuntu': {
      include apt
      apt::ppa { 'ppa:arjan-scherpenisse/zotonic': }
      package { 'zotonic':
        ensure => present
      }
    }
    default: {
      # Set permissions on Zotonic directory
      file { $dir:
        ensure  => directory,
        owner   => $user,
        group   => $user,
        recurse => true,
        require => User[$user],
      }

      if !defined(Package['git']) {
        package { 'git':
          ensure => present
        }
      }

      vcsrepo { $dir:
        ensure   => present,
        provider => git,
        source   => 'git://github.com/zotonic/zotonic.git',
        revision => $version,
        user     => $user,
		    require  => [ File[$dir], Package['git'] ]
      }

      # Set HOME to prevent 'erlexec: HOME must be set'
      exec { 'make zotonic':
        command     => '/usr/bin/make',
        cwd         => $dir,
        require     => [ Vcsrepo[$dir], Package[$erlang_package] ],
        environment => 'HOME=/home/vagrant',
        creates     => "${dir}/ebin"
      }

      # Create Zotonic service
      file { '/etc/init.d/zotonic':
        content => template('zotonic/service.erb'),
        mode    => 'a+x',
        require => Exec['make zotonic'],
        before  => Service['zotonic']
      }

      # Create symlink to the zotonic binary, so it can be called system-wide
      file { '/usr/local/bin/zotonic':
        target => "${dir}/bin/zotonic"
      }
    }
  }

  # Configure Zotonic
  file { "${dir}/priv/config":
    content => template('zotonic/config.erb'),
    notify  => Service['zotonic']
  }

  # Start Zotonic service
  service { 'zotonic':
    ensure  => running
  }
}