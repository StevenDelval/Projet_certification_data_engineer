variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group where all resources will be deployed."
}

variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "The Azure region where the resource group and its associated resources will be deployed."
}

variable "log_storage" {
  type        = string
  description = "The name of the Azure storage account used for function logs."
}

variable "log_storage_primary_access_key" {
  type        = string
  description = "The primary access key of the storage account used for logs."
}

variable "service_plan_weather_func_name" {
  type        = string
  description = "The name of the Azure App Service plan used to host the Function App."
}

variable "weather_function_name" {
  type        = string
  description = "The name of the Azure Function that will be deployed."
}
variable "application_insights_connection_string" {
  type        = string
  description = "The name of the Azure Function that will be deployed."
}
variable "application_insights_key" {
  type        = string
  description = "The name of the Azure Function that will be deployed."
}
