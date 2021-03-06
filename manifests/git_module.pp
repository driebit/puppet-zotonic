# Install a custom module from any Git repository
define zotonic::git_module(
  $version = 'master',
  $url
) {
  vcsrepo { "${zotonic::modules_dir}/${name}":
    ensure   => present,
    provider => git,
    source   => $url,
    revision => $version,
    user     => $zotonic::user,
  }
}
