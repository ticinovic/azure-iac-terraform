variable "web_app_name" {
  description = "The name of the Web App."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "app_service_sku" {
  description = "The SKU for the App Service Plan."
  type        = string
}

variable "app_service_subnet_id" {
  description = "The ID of the subnet for VNet integration."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

# ADDED: Variables to pass in ACR details from the root module
variable "acr_login_server" {
  description = "The login server of the Azure Container Registry."
  type        = string
}

variable "acr_admin_username" {
  description = "The admin username for the ACR."
  type        = string
  sensitive   = true
}

variable "acr_admin_password" {
  description = "The admin password for the ACR."
  type        = string
  sensitive   = true
}