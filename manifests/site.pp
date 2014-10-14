# Prepares Zotonic and PostgreSQL for a site
# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site
(
  $dir = undef,                        # Directory that contains the site if different than
                                       # the Zotonic sites dir
  $admin_password = 'admin',           # Administrator password (defaults to admin)
  $db_name        = $zotonic::db_name, # PostgreSQL database for the site (defaults to Zotonic db)
  $db_user        = $zotonic::db_username, # PostgreSQL user for the site
  $db_password    = $zotonic::db_password, # PostgreSQL password for the site
  $db_schema      = 'public',          # PostgreSQL schema for the site (defaults to public)
  $hostname       = undef,             # Site hostname
  $port           = 8000,              # Site port (defaults to 8000)
  $config_dir     = 'config.d',        # Directory that config_file will be placed in
  $config_file    = 'puppet',          # Name of config file,
  $enabled        = true,              # Whether site is available,
  $hostaliases    = [],
) {
  include zotonic
  
  if undef == $dir {
    # Generic Zotonic sites dir   
    $site_dir = "${zotonic::sites_dir}/${name}"
  } else {
    # Some other sites dir
    $site_dir = $dir
  }
  
  $site_config_dir = "${site_dir}/${config_dir}"
  
  # If each site runs in a separate database
  if $db_name != $zotonic::db_name {
    zotonic::db { $db_name:
      username => $db_user,
      password => $db_password,
    }
  }

  # If sites share a database they each need their own schema
  # The default schema 'public' is assumed to exist.
  if $db_schema != 'public' {
    zotonic::schema { "${db_name}_${db_schema}":
      db => $db_name,
    }
  }

  # Add site to /etc/hosts
  host { $hostname:
    ip => '127.0.0.1',
  }

  # Create a config file in config.d
  if $config_dir and $config_file {
    if !defined(File[$site_config_dir]) {
      file { $site_config_dir:
        ensure => directory,
      }
    }

    file { "${site_config_dir}/${config_file}":
      content => template('zotonic/site-config.erb'),
      require => File[$site_config_dir],
    }
  }

  if $dir {
    # Create a symlink in the Zotonic sites directory
    file { "${zotonic::sites_dir}/${name}":
      target => $site_dir,
      owner  => $zotonic::user,
    }
  }
}
