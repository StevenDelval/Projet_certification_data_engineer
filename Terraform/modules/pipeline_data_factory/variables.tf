variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group where all resources will be deployed."
}

variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "The Azure region where the resource group and its resources will be deployed."
}

variable "data_factory_name" {
  type        = string
  description = "The name of the Azure data factory resource."
}