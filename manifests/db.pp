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
}
