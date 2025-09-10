variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "project_name"        { type = string }
variable "environment"         { type = string }

variable "address_space"           { type = list(string) }
variable "app_service_subnet_cidr" { type = string }
variable "endpoint_subnet_cidr"    { type = string }

variable "tags" { type = map(string) }
