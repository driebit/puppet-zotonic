# Create PostgreSQL user
define zotonic::db_user
(
  $create_db,
) {
  include zotonic

  postgresql::server::role { $name:
    createdb => $create_db
  }
}
