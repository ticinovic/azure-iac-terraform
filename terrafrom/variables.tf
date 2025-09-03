# terraform/variables.tf

variable "project_name" {
  type        = string
  description = "A short, unique name for the project, used to prefix resource names."
  default     = "secureapp"
}

variable "environment" {
  type        = string
  description = "The deployment environment name (e.g., dev, stg, prod)."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
  default     = "West Europe"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default = {
    project = "Secure Azure IaC"
    env     = "Development"
  }
}