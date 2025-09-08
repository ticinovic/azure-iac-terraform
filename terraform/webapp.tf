# App Service Plan (Linux, Premium SKU radi VNet integracije)
resource "azurerm_service_plan" "asp" {
  name                = "asp-${local.base_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  os_type  = "Linux"
  sku_name = var.app_service_plan_sku

  tags = var.tags
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    # Forsiraj sav izlaz kroz VNet
    vnet_route_all_enabled = true

    # Minimalni runtime (primjer: Node 18 LTS)
    application_stack {
      node_version = "18-lts"
    }

    # OGRANIČENJE PRISTUPA (ingress) — dozvoli samo iz app podmreže, ostalo deny
    ip_restriction {
      name                      = "allow-app-subnet"
      priority                  = 100
      action                    = "Allow"
      virtual_network_subnet_id = azurerm_subnet.app_subnet.id
    }
    ip_restriction {
      name        = "deny-all"
      priority    = 200
      action      = "Deny"
      ip_address  = "0.0.0.0/0"
      description = "Deny everything else"
    }
  }

  tags = var.tags
}

# VNet Integration (Swift)
resource "azurerm_app_service_virtual_network_swift_connection" "swift" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.app_subnet.id
}
