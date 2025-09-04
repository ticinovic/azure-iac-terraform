# terraform/webapp.tf

# App Service Plan (Premium za VNet integration)
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

# Linux Web App (Managed Identity + Access Restrictions)
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  identity { type = "SystemAssigned" }

  site_config {
    always_on              = true
    vnet_route_all_enabled = true

    # Prilagodi runtime ako treba (node/python/dotnet/java ili docker)
    application_stack {
      node_version = "18-lts"
    }

    # Dozvoli samo promet iz tvog VNet subnet-a
    ip_restriction {
      name                      = "allow-app-vnet"
      priority                  = 100
      action                    = "Allow"
      virtual_network_subnet_id = azurerm_subnet.app_service_subnet.id
    }

    # Zabrani sve ostalo
    ip_restriction {
      name       = "deny-all"
      priority   = 65500
      action     = "Deny"
      ip_address = "0.0.0.0/0"
    }
  }


  tags = var.tags
}

# VNet integracija (App Service ↔ VNet)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = azurerm_subnet.app_service_subnet.id
}

# (Opcionalno) deploy sample iz Azure repo-a – OK i s restrikcijama
resource "azurerm_app_service_source_control" "main" {
  app_id   = azurerm_linux_web_app.main.id
  repo_url = "https://github.com/Azure-Samples/html-docs-hello-world"
  branch   = "master"
}
