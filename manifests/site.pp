# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site (
  $dir,
  $db_name     = 'zotonic',
  $db_user     = 'zotonic',
  $db_password = 'zotonic',
) {
  include zotonic

  postgresql::server::role { $db_user:
  }

  postgresql::server::db { $db_name:
    user     => $db_user,
    owner    => $db_user,
    password => $db_password,
    encoding => 'UTF8',
    require  => Postgresql::Server::Role[$db_user],
  }

  postgresql_psql { 'CREATE LANGUAGE "plpgsql"':
    unless    => "SELECT lanname FROM pg_language WHERE lanname='plpgsql'",
    db        => $db_name,
	  require   => Postgresql::Server::Db[$db_name]
  }

  # Add site to /etc/hosts
  host { $name:
    ip => '127.0.0.1',
  }

  # Create a symlink in the zotonic/priv/sites directory
  file { "${zotonic::dir}/priv/sites/${name}":
    target => $dir,
    notify => Service['zotonic']
  }
}