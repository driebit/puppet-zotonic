# Create PostgreSQL user
define zotonic::db_user
(
  $create_db,
  $password,
) {
  include zotonic

  postgresql::server::role { $name:
    createdb => $create_db,
    password_hash => $password,
  }
}
