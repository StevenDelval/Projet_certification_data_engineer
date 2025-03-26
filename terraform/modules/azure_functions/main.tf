# Définition du plan de service Azure pour l'application fonction
resource "azurerm_service_plan" "service_plan_func" {
  name                = var.service_plan_func_name
  
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  os_type             = "Linux"
  sku_name            = "Y1"  
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
  app_settings = var.app_settings
  
  # Configuration spécifique du site pour l'application fonction
  site_config {
    application_stack {
      python_version = "3.10"
    }
    # Paramètres de configuration pour Application Insights
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key = var.application_insights_key 
  }
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

resource "null_resource" "publish_function" {
  provisioner "local-exec" {
    working_dir = var.function_source_dir

    command = "func azure functionapp publish ${var.function_name}"
  }
  depends_on = [ azurerm_linux_function_app.function_app ]
}


data "azurerm_function_app_host_keys" "app_key" {
  name                = var.function_name
  resource_group_name = var.resource_group_name
  depends_on = [ azurerm_linux_function_app.function_app, null_resource.publish_function]
}

output "function_key" {
  value = data.azurerm_function_app_host_keys.app_key.default_function_key
  sensitive = true
}