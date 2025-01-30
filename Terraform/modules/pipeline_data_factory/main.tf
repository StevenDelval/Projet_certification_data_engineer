resource "azurerm_data_factory" "data_factory" {
  name                     = var.data_factory_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  identity {
    type = "SystemAssigned"
  }
}