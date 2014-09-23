# Install Zotonic module from Zotonic Modules Repository
define zotonic::module::install
{
  zotonic::command { "modules install ${name}":
    creates => "${zotonic::module_dirdir}/${name}"
  }
}
