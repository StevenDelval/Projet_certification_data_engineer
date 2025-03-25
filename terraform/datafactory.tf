resource "azurerm_data_factory" "data_factory" {
  name                = "ADF-projet-SD"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}