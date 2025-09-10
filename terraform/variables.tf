variable "project_name" { type = string }
variable "environment"  { type = string }
variable "location"     { type = string }

variable "resource_group_name" { type = string }

variable "address_space"           { type = list(string) }
variable "app_service_subnet_cidr" { type = string }
variable "endpoint_subnet_cidr"    { type = string }

variable "app_service_sku" { type = string }     # e.g. "P1v2"
variable "runtime_stack"   { type = string }     # e.g. "NODE|18-lts"

variable "storage_account_name" { type = string }
variable "key_vault_name"       { type = string }

variable "tags" {
  type = map(string)
  default = {}
}
