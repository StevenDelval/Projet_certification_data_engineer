variable "resource_group_location" {
  description = "Localisation géographique du groupe de ressources"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources dans lequel l'application fonction sera déployée"
  type        = string
}

variable "service_plan_func_name" {
  description = "Nom du plan de service pour l'application fonction"
  type        = string
}

variable "function_name" {
  description = "Nom de l'application fonction Azure"
  type        = string
}

variable "function_storage" {
  description = "Nom du compte de stockage utilisé pour l'application fonction"
  type        = string
}

variable "function_storage_primary_access_key" {
  description = "Clé d'accès primaire du compte de stockage"
  type        = string
}

variable "azurerm_storage_account_connection_string" {
  description = "Chaîne de connexion complète du compte de stockage Azure, utilisée pour générer des SAS tokens et interagir avec les services de stockage."
  type        = string
  sensitive   = true
}

variable "function_source_dir" {
  description = "Répertoire contenant le code source de la fonction"
  type        = string
}

# Variables pour les paramètres de l'application (variables d'environnement)
variable "app_settings" {
  description = "Paramètres de l'application fonction, généralement des variables d'environnement"
  type        = map(string)
}

# Variables pour Application Insights
variable "application_insights_connection_string" {
  description = "Chaîne de connexion pour Application Insights"
  type        = string
}

variable "application_insights_key" {
  description = "Clé d'Application Insights"
  type        = string
}

# Variables pour les logs et diagnostics
variable "log_analytics_workspace_id" {
  description = "ID du workspace Log Analytics pour stocker les logs de diagnostic"
  type        = string
}