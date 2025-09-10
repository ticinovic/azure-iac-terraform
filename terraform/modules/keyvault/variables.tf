variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "key_vault_name" { type = string }
variable "tenant_id" { type = string }
variable "vnet_id" { type = string }
variable "endpoint_subnet_id" { type = string }
variable "webapp_principal_id" { type = string }

variable "tags" { type = map(string) }
