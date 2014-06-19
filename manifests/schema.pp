# Creates a database schema that is required
define zotonic::schema
(
  $schema  = $name,                 # PostgreSQL schema name
  $db      = $zotonic::db_name,     # PostgreSQL database name (defaults to Zotonic database)
  $db_user = $zotonic::db_username, # PostgreSQL username (defaults to Zotonic username)
) {
  if !defined(Class['zotonic']) {
    fail('You must include the Zotonic base class before using any Zotonic resources')
  }

  postgresql_psql { "CREATE SCHEMA ${schema}":
    unless  => "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema}'",
    db      => $db,
    require => Zotonic::Db[$db],
  }

  # Postgresql::server::grant doesn't yet support schema grants, so do it manually
  postgresql_psql { "GRANT ALL ON SCHEMA ${schema} TO ${db_user}":
    db      => $db,
    unless  => "SELECT 1 WHERE has_schema_privilege('${db_user}', '${schema}', 'USAGE')",
    require => Postgresql_psql["CREATE SCHEMA ${schema}"],
  }
}
