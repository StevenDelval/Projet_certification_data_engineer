# Définition du plan de service Azure pour l'application fonction
resource "azurerm_service_plan" "service_plan_func" {
  name                = var.service_plan_func_name
  
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  os_type             = "Linux"
  sku_name            = "Y1"  
}

# Construction du ficher zip 
data "archive_file" "function_code_blob" {
  type        = "zip"
  output_path = "/tmp/${var.function_name}.zip"
  source_dir  = var.function_source_dir
}

# Téléversement du code ZIP dans le Storage Account
resource "azurerm_storage_blob" "function_code_blob" {
  name                   = "${var.function_name}.zip"
  storage_account_name   = var.function_storage
  storage_container_name = "function-code"
  type                   = "Block"
  source                 = data.archive_file.function_code_blob.output_path
}

data "azurerm_storage_account_blob_container_sas" "function_code_blob_sas" {
  connection_string = var.azurerm_storage_account_connection_string
  container_name    = "function-code"


  permissions {
    read   = true
    write  = false
    delete = false
    list   = false
    add    = false
    create = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "168h")  # Expiration dans 168 heure
}

# Définition de l'application fonction Azure (fonction en Python)
resource "azurerm_linux_function_app" "function_app" {
  name                       = var.function_name
  

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  service_plan_id            = azurerm_service_plan.service_plan_func.id

  storage_account_name       = var.function_storage
  storage_account_access_key = var.function_storage_primary_access_key

  # Paramètres de l'application (variables d'environnement)
  app_settings = merge(var.app_settings,
  {"SCM_DO_BUILD_DURING_DEPLOYMENT" = true,
  "WEBSITE_RUN_FROM_PACKAGE" = "https://functionsprojetsd.blob.core.windows.net/function-code/${azurerm_storage_blob.function_code_blob.name}?${data.azurerm_storage_account_blob_container_sas.function_code_blob_sas.sas}"})

  # Configuration spécifique du site pour l'application fonction
  site_config {
    application_stack {
      python_version = "3.10"
    }
    # Paramètres de configuration pour Application Insights
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key = var.application_insights_key 
  }
  depends_on = [ azurerm_storage_blob.function_code_blob ]
}

data "azurerm_monitor_diagnostic_categories" "function_app_diag_categories" {
  resource_id = azurerm_linux_function_app.function_app.id
}

# Paramètres de diagnostic pour l'application fonction (logs et métriques)
resource "azurerm_monitor_diagnostic_setting" "function_app_diag" {
  # Nom des paramètres de diagnostic
  name                       = "function-app-${var.function_name}-diag-settings"
  # ID de la ressource cible pour laquelle les diagnostics sont configurés
  target_resource_id         = azurerm_linux_function_app.function_app.id
  # ID du workspace Log Analytics pour stocker les logs
  log_analytics_workspace_id = var.log_analytics_workspace_id 

  # Logs activés pour cette application fonction
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.function_app_diag_categories.log_category_types
    content {
      category = enabled_log.value
    }
  }

  # Métriques activées (ici, toutes les métriques)
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}