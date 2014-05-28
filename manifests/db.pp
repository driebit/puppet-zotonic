# Prepare a PostgreSQL database for Zotonic
define zotonic::db
(
  $username,
  $password,
) {
  include zotonic

  postgresql::server::db { $name:
    user     => $username,
    owner    => $username,
    password => $password,
    encoding => 'UTF8',
  }

  postgresql_psql { 'CREATE LANGUAGE "plpgsql"':
    unless    => "SELECT lanname FROM pg_language WHERE lanname='plpgsql'",
    db        => $name,
    require   => Postgresql::Server::Db[$name]
  }
}
