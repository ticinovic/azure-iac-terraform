variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "vnet_name" { type = string }
variable "nsg_name" { type = string }

variable "app_service_subnet_cidr" { type = string }
variable "endpoint_subnet_cidr" { type = string }

variable "tags" { type = map(string) }
