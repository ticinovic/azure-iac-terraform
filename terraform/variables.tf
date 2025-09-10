variable "project_name" { type = string }
variable "environment" { type = string }
variable "location" { type = string }

variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "nsg_name" { type = string }

variable "app_service_subnet_cidr" { type = string }
variable "endpoint_subnet_cidr" { type = string }

variable "service_plan_name" { type = string }
variable "app_service_sku" { type = string }
variable "web_app_name" { type = string }
variable "runtime_stack" { type = string }

variable "storage_account_name" { type = string }
variable "key_vault_name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}