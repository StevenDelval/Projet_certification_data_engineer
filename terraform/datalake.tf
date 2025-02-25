resource "azurerm_storage_account" "data_lake" {
  name                     = var.data_lake_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool" 
  is_hns_enabled           = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_filesystem" {
  for_each           = toset(var.filesystem_names)
  name               = each.value
  storage_account_id = azurerm_storage_account.data_lake.id
}

resource "azurerm_storage_data_lake_gen2_path" "donnees_meteo" {
  for_each = toset(var.folders_names_donnees_meteo)

  path               = "${each.value}"
  
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem[var.donnees_meteo_filesystems].name
  storage_account_id = azurerm_storage_account.data_lake.id
  resource           = "directory"
}

output "data_lake_key" {
  value     = azurerm_storage_account.data_lake.primary_access_key
  sensitive = true
}