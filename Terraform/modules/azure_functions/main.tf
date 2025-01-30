resource "azurerm_service_plan" "service_plan_weather_func" {
  name                = var.service_plan_weather_func_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "weather_function" {
  name                       = var.weather_function_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  storage_account_name       = var.log_storage
  storage_account_access_key = var.log_storage_primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan_weather_func.id


  app_settings = {
    STORAGE_ACCOUNT_NAME    = var.data_lake_name
    STORAGE_ACCOUNT_KEY     = var.data_lake_key
    FILE_SYSTEM_NAME        = var.SECRET_FILE_SYSTEM_NAME
    DIRECTORY_NAME          =var.SECRET_DIRECTORY_NAME
  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key = var.application_insights_key
    
  }
  
}