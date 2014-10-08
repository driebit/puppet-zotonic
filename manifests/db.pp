# Prepare a PostgreSQL database for Zotonic
define zotonic::db
(
  $username,  # PostgreSQL username
  $password,  # PostgreSQL password
) {
  include zotonic

  postgresql::server::db { $name:
    user     => $username,
    password => $password,
    encoding => 'UTF8',
  }

  postgresql_psql { "CREATE LANGUAGE plpgsql on ${name}":
    command   => 'CREATE LANGUAGE "plpgsql"',
    unless    => "SELECT lanname FROM pg_language WHERE lanname='plpgsql'",
    db        => $name,
    require   => Postgresql::Server::Db[$name]
  }
}
