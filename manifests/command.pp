# Execute a Zotonic CLI command
define zotonic::command(
  $creates = undef
) {
  exec { "zotonic ${name}":
    command => "${zotonic::binary} ${name}",
    user    => $zotonic::user,
    cwd     => $zotonic::dir,
    creates => $creates,
    require => Class['zotonic'],
  }
}
