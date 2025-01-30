resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = var.resource_group_name
}


resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-analytics-sd"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights" "app_insights" {
  name                = "appinsights-sd"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"
}


resource azurerm_storage_account "log" {
  name                     = "logsprojetsd"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
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

module "data_factory" {
  source = "./modules/pipeline_data_factory"

  resource_group_location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  data_factory_name = var.data_factory_name
}

module "azure_functions"{
    source = "./modules/azure_functions"
    
    resource_group_location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    log_storage = azurerm_storage_account.log.name
    log_storage_primary_access_key = azurerm_storage_account.log.primary_access_key
    service_plan_weather_func_name = var.service_plan_weather_func_name
    weather_function_name = var.weather_function_name
    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key = azurerm_application_insights.app_insights.instrumentation_key

}