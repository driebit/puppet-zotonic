# Install Zotonic module from Zotonic Modules Repository
define zotonic::module(
  $update = true,   # Keep the module up-to-date    
) {

  zotonic::command { "modules install ${name}":
    creates => "${zotonic::module_dirdir}/${name}",    
  }

  if $update {
    zotonic::command { "modules update ${name}": }
  }
}
