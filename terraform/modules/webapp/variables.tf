variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "service_plan_name" { type = string }
variable "app_service_sku" { type = string }
variable "web_app_name" { type = string }
variable "runtime_stack" { type = string }

variable "app_service_subnet_id" { type = string }

variable "tags" { type = map(string) }
