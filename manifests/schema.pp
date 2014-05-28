# Creates a database schema that is required
define zotonic::schema
(
  $schema  = $name,
  $db      = undef,
  $db_user = undef,
) {
  # If sites share a database but have their own schema.
  if $db {
    # Site-specific database
    $database = $db
  } else {
    # Fall back to general Zotonic database
    $database = $zotonic::db_name
  }

  postgresql_psql { "CREATE SCHEMA ${schema}":
    unless    => "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema}'",
    db        => $database,
    require   => Zotonic::Db[$database],
  }

  if $db_user {
    # Site-specific database user
    $database_username = $db_user
  } else {
    # Fall back to general Zotonic database user
    $database_username = $zotonic::db_username
  }

  # Postgresql::server::grant doesn't yet support schema grants, so do it manually
  postgresql_psql { "GRANT ALL ON SCHEMA ${schema} TO ${database_username}":
    db        => $database,
    unless    => "SELECT 1 WHERE has_schema_privilege('${database_username}', '${schema}', 'USAGE')",
    require   => Zotonic::Db[$database],
  }
}
