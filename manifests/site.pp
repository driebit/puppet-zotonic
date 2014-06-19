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
  $config_file    = 'puppet'           # Config file that will be placed in $dir/config.d,
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
  if $hostname {
    file { "${dir}/config.d":
      ensure => directory,
    }

    file { "${dir}/config.d/${config_file}":
      content => template('zotonic/site-config.erb'),
      require => File["${dir}/config.d"],
      notify  => Service['zotonic']
    }
  }

  # Create a symlink in the zotonic/priv/sites directory
  file { "${zotonic::dir}/priv/sites/${name}":
    target => $dir,
    notify => Service['zotonic']
  }
}
