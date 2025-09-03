# terraform/main.tf

# Data source to get information about the current Azure subscription contxt
data "azurerm_client_config" "current" {}

# Create the main resource group to hold all infrastructure components
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}