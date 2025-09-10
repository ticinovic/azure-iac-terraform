resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = split("|", var.runtime_stack)[1] # expects "NODE|18-lts"
    }
  }

  # App settings (add Key Vault refs later if needed)
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "0"
  }
}

# VNet Integration (regional)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.app_service_subnet_id
}

# Access Restrictions (deny public)
resource "azurerm_app_service_access_restriction" "deny_all_public" {
  priority                = 2147483647
  name                    = "deny-public"
  action                  = "Deny"
  ip_address              = "0.0.0.0/0"
  http_headers            = []
  scm_site                = true
  use_same_restrictions_for_scm = true

  webapp_name             = azurerm_linux_web_app.main.name
  resource_group_name     = var.resource_group_name
}
