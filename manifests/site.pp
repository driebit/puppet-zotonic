# Prepares Zotonic and PostgreSQL for a site
# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site
(
  $dir = "${zotonic::sites_dir}/${name}", # Directory that contains the site
                                       # the Zotonic sites dir
  $admin_password = 'admin',           # Administrator password (defaults to admin)
  $db_name        = $zotonic::db_name, # PostgreSQL database for the site (defaults to Zotonic db)
  $db_user        = $zotonic::db_username, # PostgreSQL user for the site
  $db_password    = $zotonic::db_password, # PostgreSQL password for the site
  $db_schema      = 'public',          # PostgreSQL schema for the site (defaults to public)
  $hostname       = undef,             # Site hostname
  $port           = undef,             # Site port for in hostname (default none)
  $config_dir     = undef,             # Directory that config_file will be placed in
  $config_file    = 'puppet',          # Name of config file (set to undef to not create file)
  $enabled        = true,              # Whether site is available,
  $hostaliases    = [],
  $redirect       = true,              # Redirect hostaliases to the main url, default true
  $seo_noindex    = $zotonic::seo_noindex, # Prevent search engines from indexing the site
  $protocol       = $zotonic::protocol, # Site protocol: http or https
) {
  include zotonic
  
  # If config_dir is undef, assume site/config.d.
  # If config_dir is set, use that instead. This allows users to place the site
  # config outside the site dir itself, for instance when doing versioned 
  # deployments of the site with symlinks from each config.d dir to a shared
  # config.d dir.
  if undef == $config_dir {
    # Default config dir
    $site_config_dir = "${dir}/config.d"
  } else {
    $site_config_dir = $config_dir
  }

  if undef == $db_name {
    $site_db_name = $title
  } else {
    $site_db_name = $db_name
  }

  # If each site runs in a separate database
  if $site_db_name != $zotonic::db_name {
    zotonic::db { $site_db_name:
      username => $db_user,
      password => $db_password,
    }
  }

  # If sites share a database they each need their own schema
  # The default schema 'public' is assumed to exist.
  if $db_schema != 'public' {
    zotonic::schema { "${site_db_name}_${db_schema}":
      db     => $site_db_name,
      schema => $db_schema,
    }
  }

  # Create a config file in config.d
  if $config_file {
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

  # If the site dir is not in the Zotonic sites dir, create a symlink to it
  if $dir != "${zotonic::sites_dir}/${name}" {
    file { "${zotonic::sites_dir}/${name}":
      target => $dir,
      owner  => $zotonic::user,
    }
  }
}
