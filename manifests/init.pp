# Installs Zotonic
# See also https://github.com/zotonic/zotonic/blob/master/zotonic_install
class zotonic
(
  $password            = '',                 # admin password
  $listen_port         = '8000',             # Zotonic port
  $dir                 = '/opt/zotonic',     # Installation directory
  $version             = 'release-0.10.0p1', # Version to install
  $user                = 'zotonic',          # User that owns Zotonic
  $db_name             = 'zotonic',          # PostgreSQL database for Zotonic
  $db_username         = 'zotonic',          # PostgreSQL username for Zotonic
  $db_password         = '',                 # PostgreSQL password for Zotonic
  $db_host             = 'localhost',        # PostgreSQL host
  $db_port             = 5432,               # PostgreSQL port
  $erlang_package      = 'erlang',           # Erlang package name
  $imagemagick_package = '',                 # ImageMagick package name (a Zotonic dependency)
  $binary              = '/usr/local/bin/zotonic' # Zotonic binary, so it works from all dirs
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
        environment => 'HOME=/tmp/erlang', # Is this a sane default?
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
      file { $binary:
        target  => "${dir}/bin/zotonic",
        require => Exec['make zotonic']
      }
    }
  }

  # Prepare database
  zotonic::db { $db_name:
    username => $db_username,
    password => $db_password,
  }

  # Configure Zotonic
  file { "${dir}/priv/config":
    content => template('zotonic/config.erb'),
    require => Exec['make zotonic'],
    notify  => Service['zotonic']
  }

  # Start Zotonic service
  service { 'zotonic':
    ensure  => running
  }
}
