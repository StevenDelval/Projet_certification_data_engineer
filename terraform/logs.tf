# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-analytics-sd"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights lié à Log Analytics
resource "azurerm_application_insights" "app_insights" {
  name                = "appinsights-sd"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"
}

