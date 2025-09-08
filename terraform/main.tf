locals {
  rg_name     = "rg-${var.project_name}-${var.environment}"
  base_name   = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}
