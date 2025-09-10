# modules/webapp/main.tf

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
    # Expecting runtime_stack like "NODE|18-lts"; grab the version part
    application_stack {
      node_version = split("|", var.runtime_stack)[1]
    }

    # 🔒 Access restrictions: deny all by default (for both main site and SCM/Kudu site)
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"

    # (Optional) allow from a VNet subnet explicitly, if you want to permit inbound from inside VNet:
    # ip_restriction {
    #   name                      = "allow-appsvc-subnet"
    #   priority                  = 100
    #   action                    = "Allow"
    #   virtual_network_subnet_id = var.app_service_subnet_id
    # }
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "0"
  }
}

# VNet Integration (regional swift connection)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.app_service_subnet_id
}
