# Execute a Zotonic CLI command
define zotonic::command(
  $creates = undef
) {
  exec { "zotonic ${name}":
    command     => "${zotonic::binary} ${name}",
    user        => $zotonic::user,
    cwd         => $zotonic::dir,
    creates     => $creates,
    require     => Class['zotonic'],
    # Puppet does not set $HOME when doing exec as different user, but we need 
    # it for Zotonic to find the config files.
    environment => "HOME=/home/${zotonic::user}", 
  }
}
