# Installs Zotonic modules
define zotonic::module
{
  exec { "zotonic modules install ${name}":
    command => "${zotonic::binary} modules install ${name}",
    cwd     => $zotonic::dir,
    creates => "${zotonic::dir}/priv/modules/${name}",
    require => Class['zotonic'],
  }
}
