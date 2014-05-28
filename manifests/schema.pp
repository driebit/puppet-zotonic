# Creates a database schema that is required
define zotonic::schema
(
  $schema = $name,
  $db     = undef,
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
}
