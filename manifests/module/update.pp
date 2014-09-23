# Update Zotonic module from Zotonic Modules Repository
define zotonic::module::update
{
  Zotonic::Module::Install <| |> -> Zotonic::Module::Update <| |>

  zotonic::command { "modules update ${name}": }
}
