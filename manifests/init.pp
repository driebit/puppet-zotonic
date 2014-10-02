# Installs Zotonic
# See also https://github.com/zotonic/zotonic/blob/master/zotonic_install
class zotonic
(
  $version,                                  # Version to install              
  $password            = '',                 # admin password
  $listen_ip           = 'any',              # Listen IP address
  $listen_port         = '8000',             # Zotonic port
  $dir                 = $zotonic::params::dir,         # Installation directory
  $sites_dir           = $zotonic::params::sites_dir,   # User sites dir
  $modules_dir         = $zotonic::params::modules_dir, # Zotonic modules dir
  $config_dir          = "/home/${user}/.zotonic",
  $user                = $zotonic::params::user, # User that owns Zotonic
  $db_name             = 'zotonic',          # PostgreSQL database for Zotonic
  $db_username         = 'zotonic',          # PostgreSQL username for Zotonic
  $db_password         = '',                 # PostgreSQL password for Zotonic
  $db_host             = 'localhost',        # PostgreSQL host
  $db_port             = 5432,               # PostgreSQL port
  $timezone            = $zotonic::params::timezone,
  $erlang_package      = 'erlang',           # Erlang package name
  $imagemagick_package = '',                 # ImageMagick package name (a Zotonic dependency)
  $binary              = '/usr/local/bin/zotonic', # Zotonic binary, so it works from all dirs
  $source              = 'git://github.com/zotonic/zotonic.git',
  $template_modified_check = true,
  $deps                = []
) inherits ::zotonic::params {

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
        source   => $source,
        revision => $version,
        user     => $user,
        require  => [ File[$dir], Package['git'] ],
        notify   => Exec['make zotonic'], 
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

  # Zotonic <= 0.10 config file
  file { "${dir}/priv/config":
    content => template('zotonic/config.erb'),
    require => Vcsrepo[$dir],
    notify  => Service['zotonic']
  }

  file { $config_dir:
    ensure  => directory,
    owner   => $user,
    require => Vcsrepo[$dir],
  }

  # Create parent dir for sites and modules (Zotonic >= 0.11)
  file { "${dir}/user":
    ensure  => directory,
    owner   => $user,
    require => File[$dir],
  }  

  # Created by Zotonic on first start, but create it here so we can add sites/
  # symlinks to it before starting Zotonic
  file { $sites_dir:
    ensure  => directory,
    owner   => $user,
    require => File["${dir}/user"],
  }
  
  # Zotonic >= 0.11 config files
  file { "${config_dir}/zotonic.config":
    content => template('zotonic/zotonic.config.erb'),
    owner   => $user,
    require => File[$config_dir],
    notify  => Service['zotonic'],
  }
  
  file { "${config_dir}/erlang.config":
    content => template('zotonic/erlang.config.erb'),
    owner   => $user,
    require => File[$config_dir],
    notify  => Service['zotonic'],
  }
  
  # Start Zotonic service
  service { 'zotonic':
    ensure  => running
  }
}
