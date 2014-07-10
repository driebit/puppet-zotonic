# Prepares Zotonic and PostgreSQL for a site
# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site
(
  $dir,                                # Directory that contains the site
  $admin_password = 'admin',           # Administrator password (defaults to admin)
  $db_name        = $zotonic::db_name, # PostgreSQL database for the site (defaults to Zotonic db)
  $db_user        = undef,             # PostgreSQL user for the site
  $db_password    = undef,             # PostgreSQL password for the site
  $db_schema      = 'public',          # PostgreSQL schema for the site (defaults to public)
  $hostname       = undef,             # Site hostname
  $port           = 8000,              # Site port (defaults to 8000)
  $config_dir     = "${dir}/config.d", # Directory that config_file will be placed in
  $config_file    = 'puppet'           # Name of config file
) {
  include zotonic

  # If each site runs in a separate database
  if $db_name != $zotonic::db_name {
    zotonic::db { $db_name:
      username => $db_user,
      password => $db_password,
    }
  }

  # If sites share a database they each need their own schema
  if $db_schema {
    zotonic::schema { $db_schema:
      db => $db_name,
    }
  }

  # Add site to /etc/hosts
  host { $hostname:
    ip => '127.0.0.1',
  }

  # Create a config file in config.d
  if $config_dir and $config_file {
    if !defined(File[$config_dir]) {
      file { $config_dir:
        ensure => directory,
      }
    }

    file { "${config_dir}/${config_file}":
      content => template('zotonic/site-config.erb'),
      require => File[$config_dir],
      notify  => Service['zotonic']
    }
  }

  # Create a symlink in the zotonic/priv/sites directory
  file { "${zotonic::dir}/priv/sites/${name}":
    target => $dir,
    notify => Service['zotonic']
  }
}
