# Compte de stockage pour stocker les fonctions
resource "azurerm_storage_account" "function_code_blob" {
  name                     = "functionsprojetsd"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Création du conteneur de stockage pour le code de la Function App
resource "azurerm_storage_container" "function_code_container" {
  name                  = "function-code"
  storage_account_id    = azurerm_storage_account.function_code_blob.id
  container_access_type = "private"
}

module "azure_functions"{
    source = "./modules/azure_functions"

    service_plan_func_name = "sp-weather-func-sd"
    function_name = "get-weather-data-projet-sd"
    
    resource_group_location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    
    function_storage = azurerm_storage_account.function_code_blob.name
    function_storage_primary_access_key = azurerm_storage_account.function_code_blob.primary_access_key
    function_source_dir = "../azure_functions/collecte_csv"

    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key = azurerm_application_insights.app_insights.instrumentation_key
    
    app_settings = {
        "data_lake_name" = azurerm_storage_account.data_lake.name
        "data_lake_key" = azurerm_storage_account.data_lake.primary_access_key
        "SECRET_DIRECTORY_NAME" = "donnees-meteo"
        "SECRET_FILE_SYSTEM_NAME" = "quotidien"
        "WEBSITE_RUN_FROM_PACKAGE" = "https://${azurerm_storage_account.function_code_blob.name}.blob.core.windows.net/${azurerm_storage_container.function_code_container.name}/${azurerm_storage_blob.function_code_blob.name}${azurerm_storage_blob.function_code_blob.sas}"
        }

    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
}

