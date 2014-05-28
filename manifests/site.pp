# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site
(
  $dir,
  $db_name     = undef,
  $db_user     = undef,
  $db_password = undef,
  $db_schema   = undef,
  $hostname    = undef,
) {
  include zotonic

  # If each site runs in a separate database
  if $db_name {
    zotonic::db { $db_name:
      username => $db_user,
      password => $db_password,
    }
  }

  # If sites share a database they each need their own schema
  if $db_schema {
    zotonic::schema { $db_schema:
      db    => $db_name,
    }
  }

  # Add site to /etc/hosts
  host { $name:
    ip => '127.0.0.1',
  }

  # Create a config file in config.d
  if $hostname {
    file { "${dir}/config.d":
      ensure => directory,
    }

    file { "${dir}/config.d/ginger":
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
