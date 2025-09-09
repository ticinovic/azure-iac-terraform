# General
variable "project_name" {
  type        = string
  description = "Short project name used in resource names."
  default     = "secureapp"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stg/prod)."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region display name."
  default     = "West Europe"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources."
  default = {
    project = "Secure Azure IaC"
    env     = "Development"
  }
}

# Networking
variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet."
  default     = ["10.0.0.0/16"]
}

variable "app_service_subnet_prefix" {
  type        = list(string)
  description = "Address prefix for the App Service integration subnet."
  default     = ["10.0.1.0/24"]
}

variable "endpoint_subnet_prefix" {
  type        = list(string)
  description = "Address prefix for the Private Endpoints subnet."
  default     = ["10.0.2.0/24"]
}

# App Service Plan
variable "app_service_sku" {
  type        = string
  description = "SKU for the App Service Plan (Premium required for VNet integration)."
  default     = "P1v2"
}

# Resource names (adjust if you need globally unique values)
variable "storage_account_name" {
  type        = string
  description = "Storage Account name (3–24 chars, [a-z0-9], globally unique)."
  default     = "stsecureappdev01"
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name (3–24 chars, [a-z0-9-], globally unique)."
  default     = "kv-secureapp-dev01"
}
