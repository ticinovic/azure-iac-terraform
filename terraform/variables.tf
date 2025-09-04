# terraform/variables.tf

# Općenito
variable "project_name" {
  type        = string
  description = "Short project name used in resource names."
  default     = "secureapp"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prod)."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region display name."
  default     = "West Europe"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default = {
    project = "Secure Azure IaC"
    env     = "Development"
  }
}

# Mreža
variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "app_service_subnet_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "endpoint_subnet_prefix" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

# App Service Plan
variable "app_service_sku" {
  type        = string
  description = "Premium SKU potreban za VNet integration."
  default     = "P1v2"
}

# Imena resursa (moguće ih promijeniti po želji)
variable "storage_account_name" {
  type        = string
  description = "3–24, [a-z0-9], globalno jedinstveno."
  default     = "stsecureappdev01"
}

variable "key_vault_name" {
  type        = string
  description = "3–24, [a-z0-9-], globalno jedinstveno."
  default     = "kv-secureapp-dev01"
}
