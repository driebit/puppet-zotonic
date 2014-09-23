# Install Zotonic module from Zotonic Modules Repository
define zotonic::module(
  $update = true,   # Keep the module up-to-date    
) {
  zotonic::module::install { "${name}": }

  if $update {
    zotonic::module::update { "${name}": }
  }
}
