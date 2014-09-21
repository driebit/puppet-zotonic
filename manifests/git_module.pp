# Install a custom module from any Git repository
define zotonic::git_module(
  $version = 'master',
  $url
) {
  vcsrepo { "${zotonic::module_dir}/${name}":
    ensure   => latest,
    provider => git,
    source   => $url,
    revision => $version,
    user     => $zotonic::user,
  }
}
