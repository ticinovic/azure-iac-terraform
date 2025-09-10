resource "azurerm_service_plan" "main" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = var.web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  identity { type = "SystemAssigned" }

  site_config {
    application_stack {
      node_version = split("|", var.runtime_stack)[1]
    }
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "0"
    # (No Key Vault references here; secrets are created/managed outside TF)
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.app_service_subnet_id
}
