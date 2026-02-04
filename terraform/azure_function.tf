# Compte de stockage pour stocker les fonctions
resource "azurerm_storage_account" "function_code_blob" {
  name                     = "azsfunctionsprojetsd"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Création du conteneur de stockage pour le code de la Function App
resource "azurerm_storage_container" "function_code_container" {
  name                  = "function-code"
  storage_account_name  = azurerm_storage_account.function_code_blob.name
  container_access_type = "private"
}

module "azure_functions_weather_data"{
    source = "./modules/azure_functions"

    service_plan_func_name = "azs-sp-weather-func-sd"
    function_name = "azs-get-weather-data-projet-sd"
    endpoint = "collecte_csv_weather_data"
    
    resource_group_location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    
    function_storage = azurerm_storage_account.function_code_blob.name
    function_storage_primary_access_key = azurerm_storage_account.function_code_blob.primary_access_key
    azurerm_storage_account_connection_string = azurerm_storage_account.function_code_blob.primary_connection_string
    function_source_dir = "../azure_functions/collecte_csv"

    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key = azurerm_application_insights.app_insights.instrumentation_key
    
    app_settings = {
        "STORAGE_ACCOUNT_NAME" = azurerm_storage_account.data_lake.name
        "STORAGE_ACCOUNT_KEY" = azurerm_storage_account.data_lake.primary_access_key
        "FILE_SYSTEM_NAME" = "donnees-meteo"
        "DIRECTORY_NAME" = "quotidien"
        }

    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
    depends_on = [ azurerm_storage_container.function_code_container ]
}

module "azure_functions_api" {
    source = "./modules/azure_functions"

    service_plan_func_name = "azs-sp-api-hubeau-func-sd"
    function_name = "azs-get-hubeau-api-data-projet-sd"
    endpoint = "collecte_api_hubeau_data"
    
    resource_group_location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    
    function_storage = azurerm_storage_account.function_code_blob.name
    function_storage_primary_access_key = azurerm_storage_account.function_code_blob.primary_access_key
    azurerm_storage_account_connection_string = azurerm_storage_account.function_code_blob.primary_connection_string
    function_source_dir = "../azure_functions/collecte_api"

    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key = azurerm_application_insights.app_insights.instrumentation_key
    
    app_settings = {
        "STORAGE_ACCOUNT_NAME" = azurerm_storage_account.data_lake.name
        "STORAGE_ACCOUNT_KEY" = azurerm_storage_account.data_lake.primary_access_key
        "FILE_SYSTEM_NAME" = "donnees-piezometre"
        "DIRECTORY_NAME" = "quotidien"
        }

    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
    depends_on = [ azurerm_storage_container.function_code_container ]
}