variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group where all resources will be deployed."
}

variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "The Azure region where the resource group and its resources will be deployed."
}

variable "data_lake_name" {
  type        = string
  description = "The name of the Azure Data Lake Storage account."
}

variable "filesystem_names" {
  type        = list(string)
  description = "A list of filesystem names to be created in the Data Lake Storage account."
}

variable "donnees_meteo_filesystems" {
  type        = string
  description = "The name of the filesystem storing weather data in the Data Lake Storage account."
}

variable "folders_names_donnees_meteo" {
  type        = list(string)
  description = "A list of folder names to be created within the weather data filesystem in the Data Lake."
}

variable "data_factory_name" {
  type        = string
  description = "The name of the Azure data factory resource."
}

variable "service_plan_weather_func_name" {
  type        = string
  description = "The name of the Azure App Service plan used to host the Function App."
}

variable "weather_function_name" {
  type        = string
  description = "The name of the Azure Function that will be deployed."
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