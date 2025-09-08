variable "project_name" {
  description = "Ime projekta, koristi se u imenovanju resursa."
  type        = string
  default     = "secureapp"
}

variable "environment" {
  description = "Okruženje (npr. dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure regija."
  type        = string
  default     = "westeurope"
}

variable "vnet_address_space" {
  description = "CIDR za VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_cidr" {
  description = "CIDR za App Service (VNet Integration) podmrežu."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "endpoint_subnet_cidr" {
  description = "CIDR za Private Endpoint podmrežu."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "app_service_plan_sku" {
  description = "SKU za App Service Plan (PremiumV2/V3 potreban za VNet Integration)."
  type        = string
  default     = "P1v2"
}

variable "storage_account_name" {
  description = "Unikatno ime Storage Accounta (3-24 lower alnum)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Zajedničke oznake na resursima."
  type        = map(string)
  default = {
    owner       = "iac"
    environment = "dev"
    data_class  = "internal"
    managed_by  = "terraform"
  }
}
