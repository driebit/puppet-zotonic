# See http://zotonic.com/docs/latest/tutorials/install-addsite.html
define zotonic::site (
  $dir         = '/vagrant',
  $db_name     = 'zotonic',
  $db_user     = 'zotonic',
  $db_password = 'zotonic',
  $skeleton    = 'blog'
) {
  include zotonic

  postgresql::server::db { $db_name:
    user     => $db_user,
    owner    => $db_user,
    password => $db_password,
    encoding => 'UTF8',
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