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
  description = "The name of the Azure Storage Account used for storing function logs."
}

variable "log_storage_primary_access_key" {
  type        = string
  description = "The primary access key of the storage account used for logs."
  sensitive   = true
}

variable "service_plan_weather_func_name" {
  type        = string
  description = "The name of the Azure App Service Plan hosting the Function App."
}

variable "weather_function_name" {
  type        = string
  description = "The name of the Azure Function App."
}

variable "application_insights_connection_string" {
  type        = string
  description = "The connection string for Application Insights to monitor the Function App."
  sensitive   = true
}

variable "application_insights_key" {
  type        = string
  description = "The instrumentation key for Application Insights."
  sensitive   = true
}

variable "data_lake_name" {
  type        = string
  description = "The name of the Azure Data Lake Storage Account used for storing function data."
}

variable "data_lake_key" {
  type        = string
  description = "The access key of the Azure Data Lake Storage Account."
  sensitive   = true
}

variable "SECRET_FILE_SYSTEM_NAME" {
  type        = string
  description = "The name of the file system within the Azure Data Lake Storage."
  sensitive   = true
}

variable "SECRET_DIRECTORY_NAME" {
  type        = string
  description = "The name of the directory within the file system of the Azure Data Lake Storage."
  sensitive   = true
}
