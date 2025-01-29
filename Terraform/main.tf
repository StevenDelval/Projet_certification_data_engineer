resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = var.resource_group_name
}


module "data_lake"{
    source = "./modules/data_lake_storage"

    resource_group_location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    data_lake_name = var.data_lake_name
    filesystem_names = var.filesystem_names
    donnees_meteo_filesystems = var.donnees_meteo_filesystems 
    folders_names_donnees_meteo= var.folders_names_donnees_meteo
}