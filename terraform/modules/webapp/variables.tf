variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "project_name"        { type = string }
variable "environment"         { type = string }

variable "app_service_sku"     { type = string }
variable "runtime_stack"       { type = string }
variable "app_service_subnet_id" { type = string }

variable "tags" { type = map(string) }
