variable "project_name" {
  description = "Project slug used for naming"
  type        = string
  default     = "secureapp"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Optional explicit RG name. If null, a name is composed."
  type        = string
  default     = null
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "app_service_subnet_cidr" {
  description = "CIDR for the App Service delegated subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "endpoint_subnet_cidr" {
  description = "CIDR for the Private Endpoint subnet"
  type        = string
  default     = "10.10.2.0/24"
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "P1v2"
}

variable "runtime_stack" {
  description = "Runtime stack (format: VENDOR|VERSION)"
  type        = string
  default     = "NODE|18-lts"
}

variable "storage_account_name" {
  description = "Optional explicit Storage Account name (3-24 lower alphanum). If null, it will be generated."
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Optional explicit Key Vault name. If null, it will be generated."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
